# Firestore Index Notes (Manual)

Some queries may require composite indexes. Firebase will show a console link when needed.

Likely indexes:
1) products: where isDeleted==false, isAvailable==true, isFeatured==true orderBy createdAt desc
2) products: where isDeleted==false, isAvailable==true, isNewArrival==true orderBy createdAt desc
3) products: where isDeleted==false, isAvailable==true, categoryId==X orderBy createdAt desc

If Firebase throws an index error:
- Click the provided link
- Create the index
- Wait for it to build

This is normal on free tier too.
