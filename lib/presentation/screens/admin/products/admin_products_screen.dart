import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../providers/product/product_provider.dart';
import '../../../widgets/common/app_network_image.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.adminProducts,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteConstants.adminAddProduct),
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 6),
        ],
      ),
      backgroundColor: AppColors.background,
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return _EmptyAdminProducts(
              onAdd: () => context.push(RouteConstants.adminAddProduct),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = products[index];
              final isDeleted = p.isDeleted;
              final availability = p.isAvailable && !isDeleted;

              return InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                onTap: () => context.push('/admin/products/${p.id}/edit'),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        child: AppNetworkImage(
                          url: p.thumbnailUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.categoryName.isEmpty ? 'Category: —' : 'Category: ${p.categoryName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _Chip(
                                  text: availability ? 'Active' : 'Hidden',
                                  color: availability
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  textColor: availability
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                _Chip(
                                  text: 'Stock: ${p.stock}',
                                  color: AppColors.surfaceVariant,
                                  textColor: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EmptyAdminProducts extends StatelessWidget {
  const _EmptyAdminProducts({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 14),
            Text(
              'No products yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first product so customers can start shopping.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addProduct),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.color,
    required this.textColor,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}
