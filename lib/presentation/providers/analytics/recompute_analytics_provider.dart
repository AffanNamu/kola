import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/firestore/recompute_analytics_service.dart';
import 'admin_analytics_provider.dart';

final recomputeAnalyticsServiceProvider = Provider<RecomputeAnalyticsService>((ref) {
  return RecomputeAnalyticsService(
    analyticsFs: ref.read(adminAnalyticsFirestoreProvider),
  );
});

final recomputeAnalyticsProvider =
    StateNotifierProvider<RecomputeAnalyticsController, AsyncValue<void>>((ref) {
  return RecomputeAnalyticsController(ref);
});

class RecomputeAnalyticsController extends StateNotifier<AsyncValue<void>> {
  RecomputeAnalyticsController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recomputeAnalyticsServiceProvider).run();
    });
  }
}
