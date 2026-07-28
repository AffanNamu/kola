# Product Rating Aggregation (Free Tier Safe Approach)

Avoid Cloud Functions at launch.
Approach:
- Product doc stores rating + reviewCount
- When admin approves a review, admin app recomputes rating for that product:
  query approved reviews for product (limit 200) and compute avg

This is admin-only action; low frequency; keeps reads controlled.
After revenue: move to server-side function.
