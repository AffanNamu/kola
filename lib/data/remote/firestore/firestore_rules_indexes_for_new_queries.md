# New queries added

- payments orderBy createdAt desc (admin)
- payments where orderId == X orderBy createdAt desc
- orders where createdAt >= since (analytics recompute)

If Firestore requests indexes, create them in console.
