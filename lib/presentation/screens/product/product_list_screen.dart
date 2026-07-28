import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/product/product_provider.dart';
import '../../widgets/common/app_network_image.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({
    super.key,
    required this.showCategories,
    this.categoryId,
    this.categoryName,
  });

  final bool showCategories;
  final String? categoryId;
  final String? categoryName;

  List<dynamic> _dedupeById(List<dynamic> products) {
    final map = <String, dynamic>{};
    for (final p in products) {
      map[p.id] = p;
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (categoryName?.isNotEmpty == true) ? categoryName! : 'Shop';

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              onPressed: () => context.push(RouteConstants.search),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () => context.push(RouteConstants.cart),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ],
        ),
        body: (categoryId == null || categoryId!.isEmpty)
            ? _AllProductsView(dedupe: _dedupeById)
            : _CategoryProductsView(
                categoryId: categoryId!,
                dedupe: _dedupeById,
              ),
      ),
    );
  }
}

class _AllProductsView extends ConsumerWidget {
  const _AllProductsView({required this.dedupe});
  final List<dynamic> Function(List<dynamic>) dedupe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProductsProvider);
    final newArrivals = ref.watch(newArrivalsProvider);

    // Ensure data is loaded at least once (safe in build; will no-op if already loaded)
    Future.microtask(() {
      ref.read(featuredProductsProvider.notifier).load();
      ref.read(newArrivalsProvider.notifier).load();
    });

    final combined = <dynamic>[];
    featured.whenOrNull(loaded: (x) => combined.addAll(x));
    newArrivals.whenOrNull(loaded: (x) => combined.addAll(x));

    final list = dedupe(combined);

    if (featured is _Loading || newArrivals is _Loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
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
            child: const Text('No products yet. Add products in Admin.'),
          ),
        ),
      );
    }

    return _ProductGrid(products: list);
  }
}

class _CategoryProductsView extends ConsumerWidget {
  const _CategoryProductsView({
    required this.categoryId,
    required this.dedupe,
  });

  final String categoryId;
  final List<dynamic> Function(List<dynamic>) dedupe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoryProductsProvider(categoryId));
    return async.when(
      data: (list) {
        final items = dedupe(list);
        if (items.isEmpty) {
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
                child: const Text('No products in this category yet.'),
              ),
            ),
          );
        }
        return _ProductGrid(products: items);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({required this.products});
  final List<dynamic> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];

        return InkWell(
          onTap: () => context.push('/products/${p.id}'),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  child: AppNetworkImage(
                    url: p.thumbnailUrl,
                    width: double.infinity,
                    height: 120,
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.usd(p.price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(cartControllerProvider.notifier).addToCart(
                            productId: p.id,
                            name: p.name,
                            image: p.thumbnailUrl,
                            price: p.price,
                            quantity: 1,
                            variantId: 'default',
                            variantName: '250g',
                            sku: p.sku,
                            maxStock: p.stock,
                          );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      ),
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
