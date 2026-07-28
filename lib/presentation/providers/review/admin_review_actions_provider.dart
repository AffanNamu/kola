import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/firestore/product_rating_service.dart';
import 'review_provider.dart';

final productRatingServiceProvider = Provider<ProductRatingService>((ref) {
  return const ProductRatingService();
});

final adminReviewActionsProvider =
    StateNotifierProvider<AdminReviewActionsController, AsyncValue<void>>((ref) {
  return AdminReviewActionsController(ref);
});

class AdminReviewActionsController extends StateNotifier<AsyncValue<void>> {
  AdminReviewActionsController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> approveAndRecompute({
    required String reviewId,
    required String productId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(reviewRepositoryProvider);
      final failure = await repo.approve(reviewId, true);
      if (failure != null) throw Exception(failure.message);

      await ref.read(productRatingServiceProvider).recomputeForProduct(productId);
    });
  }

  Future<void> deleteReview(String reviewId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(reviewRepositoryProvider);
      final failure = await repo.softDelete(reviewId);
      if (failure != null) throw Exception(failure.message);
    });
  }
}
