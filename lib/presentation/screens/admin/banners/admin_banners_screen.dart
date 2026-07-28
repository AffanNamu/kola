import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../data/models/banner/banner_model.dart';
import '../../../providers/banner/banner_provider.dart';
import '../../../widgets/common/app_network_image.dart';

class AdminBannersScreen extends ConsumerWidget {
  const AdminBannersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(adminBannersProvider);
    final fs = ref.read(bannerFirestoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.adminBanners),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteConstants.adminAddBanner),
            icon: const Icon(Icons.add_circle_outline),
          )
        ],
      ),
      body: SafeArea(
        child: bannersAsync.when(
          data: (banners) {
            if (banners.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingLG),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Text('No banners yet. Add one.'),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              itemCount: banners.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final b = banners[i];
                return _BannerTile(
                  banner: b,
                  onToggle: (v) => fs.update(b.copyWith(isActive: v)),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.banner, required this.onToggle});
  final BannerModel banner;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            child: AppNetworkImage(
              url: banner.imageUrl,
              width: 90,
              height: 60,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'sort: ${banner.sortOrder}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: banner.isActive,
                onChanged: onToggle,
              ),
              Text(
                banner.isActive ? 'Active' : 'Hidden',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: banner.isActive
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
