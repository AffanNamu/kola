# Supabase Edge Functions (Payment Verification Proxy)

Create 2 edge functions:

## 1) paystack-verify
URL:
https://<project-ref>.functions.supabase.co/paystack-verify?reference=xxxxx

Environment variables (Supabase):
- PAYSTACK_SECRET_KEY

Pseudo-code (Deno):
- read reference from query
- call https://api.paystack.co/transaction/verify/{reference}
- Authorization: Bearer PAYSTACK_SECRET_KEY
- return JSON: { success: true/false, status: "success"/"failed", amount, currency, raw }

## 2) flutterwave-verify
URL:
https://<project-ref>.functions.supabase.co/flutterwave-verify?transaction_id=xxxxx

Environment variables:
- FLUTTERWAVE_SECRET_KEY

Call:
GET https://api.flutterwave.com/v3/transactions/{id}/verify
Authorization: Bearer FLUTTERWAVE_SECRET_KEY

Return same JSON shape.

Then set GitHub secret:
SUPABASE_VERIFY_BASE_URL = https://<project-ref>.functions.supabase.co
