import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import 'firestore_service.dart';

class ProductRatingService {
  const ProductRatingService();

  Future<void> recomputeForProduct(String productId) async {
    final reviewsSnap = await FirestoreService.col(FirestoreConstants.reviews)
        .where('productId', isEqualTo: productId)
        .where('isApproved', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .limit(200)
        .get();

    if (reviewsSnap.docs.isEmpty) {
      await FirestoreService.col(FirestoreConstants.products).doc(productId).set(
        {
          'rating': 0.0,
          'reviewCount': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return;
    }

    double sum = 0;
    for (final d in reviewsSnap.docs) {
      final data = d.data();
      sum += (data['rating'] as num?)?.toDouble() ?? 0.0;
    }

    final count = reviewsSnap.docs.length;
    final avg = sum / count;

    await FirestoreService.col(FirestoreConstants.products).doc(productId).set(
      {
        'rating': double.parse(avg.toStringAsFixed(2)),
        'reviewCount': count,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
