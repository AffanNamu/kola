# Kola Firebase Functions

These functions are the trusted boundary for account access, payment verification, order fulfilment, product revenue aggregation and push delivery.

## Required secrets

Set the gateway secret keys in the Firebase project (never put secret keys in Flutter, GitHub variables, or Firestore):

```bash
firebase use kola-7523f
firebase functions:secrets:set PAYSTACK_SECRET_KEY
firebase functions:secrets:set FLUTTERWAVE_SECRET_KEY
```

Enter the corresponding private keys when prompted. If one gateway is not enabled for the store yet, its secret may be configured before enabling that gateway's checkout.

## Deploy

From the repository root, with Firebase CLI authenticated and access to project `kola-7523f`:

```bash
firebase deploy --only functions,firestore:rules
```

The functions use Node.js 20. Deploying requires the Firebase project to have the Blaze billing plan and the Cloud Functions, Cloud Build, Artifact Registry and Cloud Run APIs enabled. Firebase Authentication, Firestore and Cloud Messaging must also be enabled.

## Callable functions

- `setCustomerAuthDisabled`: Admin-only Firebase Authentication disable/enable, refresh-token revocation and audit event.
- `createPendingPayment`: Creates a pending payment using the order's server-stored total and links it to the order.
- `verifyPayment`: Verifies Paystack or Flutterwave with server-held credentials, checks amount/currency/reference, then atomically marks the payment and order paid.
- `updateOrderFulfilment`: Enforces allowed fulfilment transitions, shipping metadata and audit history.
- `refundOrderPayment`: Requests a refund from the payment gateway, updates payment/order state and records the audit event.

## Event functions

- `deliverInAppNotification`: Sends an FCM push for each in-app notification using the recipient's stored FCM token.
- `aggregateProductSales`: Aggregates product units and revenue once when an order first becomes paid.

## Operational notes

- The payment screen must use a real gateway checkout and pass the actual gateway reference/transaction identifier. A locally generated reference by itself is not proof of payment.
- Flutterwave's verification endpoint requires its transaction identifier; store that actual identifier with the payment before calling verification.
- The app currently registers Android FCM tokens. Configure APNs and iOS Firebase options before enabling iOS push delivery.
- Cloud Functions and Firestore rules are source-controlled here; they are not deployed automatically by a GitHub source commit.
