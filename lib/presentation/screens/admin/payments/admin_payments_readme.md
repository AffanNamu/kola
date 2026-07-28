# Admin Payments

- View all payments (pending first)
- Open detail and click:
  - Verify via Supabase (recommended)
  - Mark Paid (manual fallback)

When verification succeeds:
- payment.status -> success, verified -> true
- order.status -> paid
