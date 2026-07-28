import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/review/review_model.dart';
import '../../../data/remote/firestore/review_firestore.dart';
import '../../../data/repositories/review_repository_impl.dart';
import '../auth/auth_provider.dart';

final reviewFirestoreProvider = Provider<ReviewFirestore>((ref) {
  return const ReviewFirestore();
});

final reviewRepositoryProvider = Provider<ReviewRepositoryImpl>((ref) {
  return ReviewRepositoryImpl(ref.read(reviewFirestoreProvider));
});

final productReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, productId) {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.watchApprovedForProduct(productId);
});

final adminPendingReviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.watchAdminPending();
});

final writeReviewControllerProvider =
    StateNotifierProvider<WriteReviewController, AsyncValue<void>>((ref) {
  return WriteReviewController(ref);
});

class WriteReviewController extends StateNotifier<AsyncValue<void>> {
  WriteReviewController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> submit({
    required String productId,
    required String productName,
    required double rating,
    required String title,
    required String body,
    List<String> images = const [],
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).asData?.value;
      if (user == null) throw Exception('Please login to write a review');

      final repo = ref.read(reviewRepositoryProvider);
      final review = ReviewModel(
        id: '',
        productId: productId,
        userId: user.uid,
        userName: user.displayName.isEmpty ? 'Customer' : user.displayName,
        userAvatar: user.photoUrl,
        rating: rating,
        title: title.trim(),
        body: body.trim(),
        images: images,
        isVerifiedPurchase: false,
        isApproved: false,
        isDeleted: false,
        helpfulCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final (_, failure) = await repo.create(review);
      if (failure != null) throw Exception(failure.message);
    });
  }
}
