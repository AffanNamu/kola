# Admin Reviews

Flow:
1) Customer submits review -> isApproved=false
2) Admin approves -> isApproved=true
3) Admin app recomputes product rating and reviewCount (reads up to 200 reviews)

This avoids Cloud Functions and keeps free-tier cost low.
