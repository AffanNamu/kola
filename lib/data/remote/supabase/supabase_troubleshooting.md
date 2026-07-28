# Supabase Verify Troubleshooting

If verify fails:
1) Confirm SUPABASE_VERIFY_BASE_URL secret set in GitHub
2) Confirm edge function deployed and public
3) Confirm secrets set:
   - PAYSTACK_SECRET_KEY
   - FLUTTERWAVE_SECRET_KEY
4) Confirm the edge function returns JSON contract:
   { success, status, raw }

If you see CORS issues:
- Add proper CORS headers in the edge function response.
