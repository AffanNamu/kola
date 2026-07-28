# Analytics Seed (Manual)

Create Firestore doc:
collection: analytics
docId: adminDashboard

Example JSON:
{
  "orders30d": 0,
  "revenue30d": 0,
  "customers": 0,
  "products": 0,
  "topProducts": [],
  "updatedAtIso": ""
}

Then Admin -> Reports will show real data once you run recompute.
