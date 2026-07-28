import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../providers/analytics/recompute_analytics_provider.dart';

class AdminRecomputeAnalyticsScreen extends ConsumerWidget {
  const AdminRecomputeAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recomputeAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Recompute Analytics')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recompute Now',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Runs an aggregation over paid orders from last 30 days.\n'
                  'Use this only when needed to reduce Firestore reads.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => ref.read(recomputeAnalyticsProvider.notifier).run(),
                    icon: const Icon(Icons.refresh),
                    label: Text(state.isLoading ? 'Running...' : 'Recompute'),
                  ),
                ),
                const SizedBox(height: 12),
                state.when(
                  data: (_) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Text('Done. Open Reports to view updated stats.'),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text('Error: $e'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
