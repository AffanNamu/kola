# Atomic Payment Linking (Next Improvement)

Currently we:
1) create payment document
2) update order with paymentId + reference

This is safe enough for bootstrap, but not atomic.

Next improvement:
Use Firestore transaction:
- create payment doc with known id
- set order.paymentId in same transaction
