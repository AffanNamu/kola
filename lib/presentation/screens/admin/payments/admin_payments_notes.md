# Manual Payment Verification (Bootstrap Mode)

Why manual?
- Paystack/Flutterwave verification requires SECRET keys.
- SECRET keys must never be shipped in the mobile app.
- We avoid Cloud Functions until revenue.

Bootstrap workflow:
1) Customer places order -> order status: pending_payment
2) Customer selects payment gateway -> app creates payments doc with status: pending
3) Customer completes payment externally (or you collect bank transfer)
4) Admin checks Paystack/Flutterwave dashboard or bank receipt
5) Admin opens Admin Order Detail and enters Payment ID (Firestore doc id)
6) Admin clicks "Mark as Paid" -> payment status becomes success + order status becomes paid

After revenue:
- Add Supabase Edge Function / Cloud Function to verify references automatically.
