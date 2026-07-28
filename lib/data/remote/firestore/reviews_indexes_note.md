# Reviews Index Notes

Queries:
- reviews where productId == X AND isApproved == true AND isDeleted == false orderBy createdAt desc
- reviews where isApproved == false AND isDeleted == false orderBy createdAt desc

If Firestore requests a composite index, create it via console link.
