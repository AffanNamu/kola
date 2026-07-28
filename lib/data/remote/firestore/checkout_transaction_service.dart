import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/payment/payment_model.dart';
import 'firestore_service.dart';

class CheckoutTransactionService {
  const CheckoutTransactionService();

  Future<String> createPaymentAndLinkOrder({
    required PaymentModel payment,
    required String gateway,
    required String reference,
  }) async {
    final db = FirestoreService.db;

    final paymentsCol = db.collection(FirestoreConstants.payments);
    final ordersCol = db.collection(FirestoreConstants.orders);

    final paymentRef = paymentsCol.doc();
    final orderRef = ordersCol.doc(payment.orderId);

    await db.runTransaction((tx) async {
      // Ensure order exists
      final orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Order not found for payment link',
        );
      }

      final payload = payment.copyWith(
        id: paymentRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      tx.set(paymentRef, payload.toFirestore());

      tx.set(orderRef, {
        'paymentId': paymentRef.id,
        'paymentGateway': gateway,
        'paymentReference': reference,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    return paymentRef.id;
  }
}
