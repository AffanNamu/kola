# CheckoutTransactionService

Used for atomic payment creation + linking order.paymentId.
This prevents "payment exists but order has no paymentId" inconsistency.
