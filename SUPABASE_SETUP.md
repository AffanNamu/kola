# Supabase Edge Functions Setup (Verification Proxy)

## Why
Paystack/Flutterwave verification needs SECRET keys, which must not be inside the app.
Supabase Edge Functions safely store secrets server-side.

## Create Functions
1) supabase functions new paystack-verify
2) supabase functions new flutterwave-verify

## Environment variables (Supabase Project Settings -> Edge Functions -> Secrets)
- PAYSTACK_SECRET_KEY
- FLUTTERWAVE_SECRET_KEY

## GitHub Secret
- SUPABASE_VERIFY_BASE_URL = https://<project-ref>.functions.supabase.co

## Expected response format (from edge functions)
Return JSON:
{
  "success": true,
  "status": "success",
  "amount": 24.99,
  "currency": "USD",
  "raw": {...}
}

If failed:
{
  "success": false,
  "status": "failed",
  "raw": {...}
}
