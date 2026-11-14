import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../data/models/category/category_model.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';
import '../../../providers/category/category_provider.dart';
import '../../../widgets/common/app_network_image.dart';

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(adminCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.adminCategories),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteConstants.adminAddCategory),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: catsAsync.when(
          data: (cats) {
            if (cats.isEmpty) {
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
                    child: const Text('No categories yet. Add one.'),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = cats[i];
                final img = c.imageUrl.isNotEmpty ? c.imageUrl : c.iconUrl;

                return _CategoryTile(category: c, imageUrl: img);
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

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category, required this.imageUrl});
  final CategoryModel category;
  final String imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              url: imageUrl,
              width: 64,
              height: 64,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${category.id} • sort: ${category.sortOrder}',
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
                value: category.isActive,
                onChanged: (v) async {
                  final repo = ref.read(categoryRepositoryProvider);
                  await repo.update(category.copyWith(isActive: v));
                  await const AdminAuditFirestore().log(action: 'category_visibility_changed', targetUid: category.id, details: {'isActive': v});
                },
              ),
              Text(
                category.isActive ? 'Active' : 'Hidden',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: category.isActive ? AppColors.success : AppColors.textSecondary,
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
