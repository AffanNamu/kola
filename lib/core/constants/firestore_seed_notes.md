# Firestore Seed Notes (Manual)

## Make yourself Admin
1) Sign up / login once in the app (so user doc is created).
2) Firebase Console -> Firestore -> users -> <your_uid>
3) Set field: role = "admin"

## Recommended minimal seed data
### categories
Create at least 3 categories:
- Kolanut
- Herbs
- Powders

### products
Add products from Admin -> Products -> Add Product
IMPORTANT: set Category ID and Category Name correctly.

### banners
Add at least 1 banner from Admin -> Banners -> Add Banner

## Why this is manual
No cloud functions. No server. Free tier only.
