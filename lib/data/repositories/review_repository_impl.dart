import '../../core/errors/error_handler.dart';
import '../../core/errors/failure.dart';
import '../models/review/review_model.dart';
import '../remote/firestore/review_firestore.dart';

class ReviewRepositoryImpl {
  ReviewRepositoryImpl(this._fs);
  final ReviewFirestore _fs;

  Stream<List<ReviewModel>> watchApprovedForProduct(String productId) =>
      _fs.watchApprovedForProduct(productId);

  Stream<List<ReviewModel>> watchAdminPending() => _fs.watchAdminPending();

  Future<(String?, Failure?)> create(ReviewModel review) async {
    try {
      final id = await _fs.create(review);
      return (id, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<Failure?> approve(String reviewId, bool approved) async {
    try {
      await _fs.approve(reviewId, approved: approved);
      return null;
    } catch (e) {
      return ErrorHandler.handleException(e);
    }
  }

  Future<Failure?> softDelete(String reviewId) async {
    try {
      await _fs.softDelete(reviewId);
      return null;
    } catch (e) {
      return ErrorHandler.handleException(e);
    }
  }
}
