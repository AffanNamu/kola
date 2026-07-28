import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/review/review_model.dart';
import 'firestore_service.dart';

class ReviewFirestore {
  const ReviewFirestore();

  CollectionReference<Map<String, dynamic>> get _reviews =>
      FirestoreService.col(FirestoreConstants.reviews);

  Stream<List<ReviewModel>> watchApprovedForProduct(String productId, {int limit = 50}) {
    return _reviews
        .where('productId', isEqualTo: productId)
        .where('isApproved', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  Stream<List<ReviewModel>> watchAdminPending({int limit = 100}) {
    return _reviews
        .where('isDeleted', isEqualTo: false)
        .where('isApproved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  Future<String> create(ReviewModel review) async {
    final docRef = _reviews.doc();
    final now = DateTime.now();
    final payload = review.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
      isApproved: false, // moderation required
      isDeleted: false,
    );
    await docRef.set(payload.toFirestore());
    return docRef.id;
  }

  Future<void> approve(String reviewId, {required bool approved}) async {
    await _reviews.doc(reviewId).set(
      {
        'isApproved': approved,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> softDelete(String reviewId) async {
    await _reviews.doc(reviewId).set(
      {
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
