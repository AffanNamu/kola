import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

initializeApp();
const db = getFirestore();
const PAYSTACK_SECRET_KEY = defineSecret("PAYSTACK_SECRET_KEY");
const FLUTTERWAVE_SECRET_KEY = defineSecret("FLUTTERWAVE_SECRET_KEY");
const OWNER_UID = "L5E8FXohf6Y7HLify4ITu6eMvIZ2";

async function requireAdmin(uid?: string): Promise<void> {
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
  if (uid === OWNER_UID) return;
  const user = await db.collection("users").doc(uid).get();
  if (user.data()?.role !== "admin" || user.data()?.isActive === false) {
    throw new HttpsError("permission-denied", "Administrator access required.");
  }
}

async function audit(actorUid: string, action: string, targetUid?: string, details: Record<string, unknown> = {}) {
  await db.collection("adminActivityLogs").add({
    actorUid, action, ...(targetUid ? { targetUid } : {}),
    details, createdAt: FieldValue.serverTimestamp(), source: "trusted_backend",
  });
}

export const setCustomerAuthDisabled = onCall(async (request) => {
  await requireAdmin(request.auth?.uid);
  const { uid, disabled } = request.data as { uid?: string; disabled?: boolean };
  if (!uid || typeof disabled !== "boolean") throw new HttpsError("invalid-argument", "A customer UID and disabled boolean are required.");
  if (uid === OWNER_UID || uid === request.auth?.uid && disabled) throw new HttpsError("failed-precondition", "This account cannot be disabled.");
  const target = await getAuth().getUser(uid);
  await getAuth().updateUser(uid, { disabled });
  await db.collection("users").doc(uid).set({
    isActive: !disabled, authDisabled: disabled, updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  await audit(request.auth!.uid, disabled ? "customer_auth_disabled" : "customer_auth_enabled", uid, { previousDisabled: target.disabled, disabled });
  return { success: true, uid, disabled };
});

export const verifyPayment = onCall({ secrets: [PAYSTACK_SECRET_KEY, FLUTTERWAVE_SECRET_KEY] }, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in required.");
  const { paymentId } = request.data as { paymentId?: string };
  if (!paymentId) throw new HttpsError("invalid-argument", "Payment ID is required.");
  const paymentRef = db.collection("payments").doc(paymentId);
  const paymentSnap = await paymentRef.get();
  if (!paymentSnap.exists) throw new HttpsError("not-found", "Payment not found.");
  const payment = paymentSnap.data()!;
  const isAdmin = request.auth.uid === OWNER_UID || (await db.collection("users").doc(request.auth.uid).get()).data()?.role === "admin";
  if (!isAdmin && payment.userId !== request.auth.uid) throw new HttpsError("permission-denied", "This payment does not belong to you.");
  if (payment.status === "success" && payment.verified === true) return { success: true, status: "success", alreadyVerified: true };

  const gateway = String(payment.gateway || "");
  const reference = String(payment.reference || "");
  let response: any;
  if (gateway === "paystack") {
    const res = await fetch("https://api.paystack.co/transaction/verify/" + encodeURIComponent(reference), {
      headers: { Authorization: "Bearer " + PAYSTACK_SECRET_KEY.value() },
    });
    response = await res.json();
    if (!res.ok || response.status !== true || response.data?.status !== "success") throw new HttpsError("failed-precondition", "Paystack has not confirmed this payment.");
    const expectedKobo = Math.round(Number(payment.amount) * 100);
    if (Number(response.data.amount) !== expectedKobo || response.data.reference !== reference) throw new HttpsError("failed-precondition", "Payment amount or reference does not match.");
  } else if (gateway === "flutterwave") {
    const res = await fetch("https://api.flutterwave.com/v3/transactions/" + encodeURIComponent(reference) + "/verify", {
      headers: { Authorization: "Bearer " + FLUTTERWAVE_SECRET_KEY.value() },
    });
    response = await res.json();
    if (!res.ok || response.status !== "success" || response.data?.status !== "successful") throw new HttpsError("failed-precondition", "Flutterwave has not confirmed this payment.");
    if (Math.round(Number(response.data.amount) * 100) !== Math.round(Number(payment.amount) * 100) || response.data.currency !== payment.currency) throw new HttpsError("failed-precondition", "Payment amount or currency does not match.");
  } else {
    throw new HttpsError("invalid-argument", "Unsupported payment gateway.");
  }

  const orderRef = db.collection("orders").doc(String(payment.orderId));
  await db.runTransaction(async (tx) => {
    const orderSnap = await tx.get(orderRef);
    const freshPayment = await tx.get(paymentRef);
    if (!orderSnap.exists || !freshPayment.exists) throw new HttpsError("not-found", "Order or payment no longer exists.");
    const order = orderSnap.data()!;
    const p = freshPayment.data()!;
    if (p.userId !== order.userId || p.orderId !== orderRef.id || Math.round(Number(order.total) * 100) !== Math.round(Number(p.amount) * 100)) {
      throw new HttpsError("failed-precondition", "Payment is not linked to the expected order amount.");
    }
    if (p.verified === true && p.status === "success") return;
    tx.update(paymentRef, { status: "success", verified: true, gatewayResponse: response.data ?? response, verifiedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    tx.update(orderRef, { status: "paid", paidAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
  });
  return { success: true, status: "success" };
});

export const updateOrderFulfilment = onCall(async (request) => {
  await requireAdmin(request.auth?.uid);
  const { orderId, status, trackingNumber, courierName, note } = request.data as {
    orderId?: string; status?: string; trackingNumber?: string; courierName?: string; note?: string;
  };
  const allowed = ["confirmed", "processing", "packed", "shipped", "delivered", "cancelled", "refunded"];
  if (!orderId || !status || !allowed.includes(status)) throw new HttpsError("invalid-argument", "Invalid order transition.");
  const ref = db.collection("orders").doc(orderId);
  const before = await ref.get();
  if (!before.exists) throw new HttpsError("not-found", "Order not found.");
  const current = String(before.data()?.status || "");
  const transitions: Record<string, string[]> = {
    paid: ["confirmed", "cancelled"], confirmed: ["processing", "cancelled"],
    processing: ["packed", "cancelled"], packed: ["shipped"], shipped: ["delivered"],
    delivered: ["refunded"],
  };
  if (!transitions[current]?.includes(status)) throw new HttpsError("failed-precondition", "This order status transition is not allowed.");
  if (status === "shipped" && (!trackingNumber || !courierName)) throw new HttpsError("invalid-argument", "Courier and tracking number are required before shipping.");
  const stamp = FieldValue.serverTimestamp();
  await ref.update({
    status, updatedAt: stamp,
    ...(trackingNumber ? { trackingNumber } : {}),
    ...(courierName ? { courierName } : {}),
    ...(status === "confirmed" ? { confirmedAt: stamp } : {}),
    ...(status === "shipped" ? { shippedAt: stamp } : {}),
    ...(status === "delivered" ? { deliveredAt: stamp } : {}),
    ...(status === "cancelled" ? { cancelledAt: stamp } : {}),
    ...(note ? { fulfilmentNote: note } : {}),
    statusHistory: FieldValue.arrayUnion({ from: current, to: status, actorUid: request.auth!.uid, at: new Date().toISOString(), note: note || "" }),
  });
  await audit(request.auth!.uid, "order_status_changed", orderId, { from: current, to: status, trackingNumber: trackingNumber || null, courierName: courierName || null });
  return { success: true, previousStatus: current, status };
});

export const deliverInAppNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const uid = String(data.userId || "");
  if (!uid) return;
  const user = await db.collection("users").doc(uid).get();
  const token = user.data()?.fcmToken;
  if (typeof token !== "string" || token.isEmpty) return;
  try {
    await getMessaging().send({
      token, notification: { title: String(data.title || "Kola"), body: String(data.body || "") },
      data: { notificationId: event.params.notificationId, type: String(data.type || "general") },
      android: { priority: "high" },
    });
    await event.data?.ref.set({ pushStatus: "sent", pushSentAt: FieldValue.serverTimestamp() }, { merge: true });
  } catch (error) {
    await event.data?.ref.set({ pushStatus: "failed", pushError: String(error).slice(0, 300) }, { merge: true });
  }
});

export const aggregateProductSales = onDocumentUpdated("orders/{orderId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after || before.status === after.status || after.status !== "paid") return;
  const items = Array.isArray(after.items) ? after.items : [];
  const batch = db.batch();
  for (const item of items) {
    const productId = String(item.productId || "");
    if (!productId) continue;
    const quantity = Number(item.quantity || 0);
    const revenue = Number(item.price || 0) * quantity;
    const ref = db.collection("productSales").doc(productId);
    batch.set(ref, {
      productId, productName: String(item.productName || "Product"),
      unitsSold: FieldValue.increment(quantity), revenue: FieldValue.increment(revenue),
      paidOrders: FieldValue.increment(1), updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
  }
  if (items.length) await batch.commit();
});
