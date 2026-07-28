# Firestore Transaction Notes

We use a transaction to:
- create payment doc
- link paymentId + reference into order doc

This reduces inconsistent state and is still free-tier friendly.
