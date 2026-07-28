import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/product/product_provider.dart';
import '../../widgets/common/app_network_image.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImage = 0;
  int _qty = 1;

  String _variantId = '250g';
  String _variantName = '250g';
  double _mult = 1.0;

  Future<void> _addToCart(dynamic p) async {
    final price = p.price * _mult;
    await ref.read(cartControllerProvider.notifier).addToCart(
          productId: p.id,
          name: p.name,
          image: p.thumbnailUrl,
          price: price,
          quantity: _qty,
          variantId: _variantId,
          variantName: _variantName,
          sku: p.sku,
          maxStock: p.stock,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return productAsync.when(
      data: (p) {
        if (p == null) return const Scaffold(body: Center(child: Text('Product not found')));

        final images = p.images;
        final selectedUrl = images.isEmpty
            ? ''
            : images[_selectedImage.clamp(0, images.length - 1)];
        final displayPrice = p.price * _mult;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.productDetails),
            actions: [
              IconButton(
                onPressed: () => context.push('/products/${p.id}/reviews'),
                icon: const Icon(Icons.star_outline),
              ),
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingLG),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                              child: AppNetworkImage(
                                url: selectedUrl,
                                width: double.infinity,
                                height: 280,
                                backgroundColor: AppColors.surfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 64,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length.clamp(0, 8),
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                                  final active = i == _selectedImage;
                                  return InkWell(
                                    onTap: () => setState(() => _selectedImage = i),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                                        border: Border.all(
                                          color: active ? AppColors.primary : AppColors.borderLight,
                                          width: active ? 2 : 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                                        child: AppNetworkImage(url: images[i]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              p.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: p.rating,
                                  itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.ratingActive),
                                  itemCount: 5,
                                  itemSize: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${p.rating.toStringAsFixed(1)} (${p.reviewCount} reviews)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '\$${displayPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingLG),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Select Quantity',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _VariantChip(label: '250g', price: p.price, selected: _variantId == '250g', onTap: () => setState(() { _variantId='250g'; _variantName='250g'; _mult=1.0; })),
                                _VariantChip(label: '500g', price: p.price * 1.8, selected: _variantId == '500g', onTap: () => setState(() { _variantId='500g'; _variantName='500g'; _mult=1.8; })),
                                _VariantChip(label: '1kg', price: p.price * 3.2, selected: _variantId == '1kg', onTap: () => setState(() { _variantId='1kg'; _variantName='1kg'; _mult=3.2; })),
                                _VariantChip(label: '2kg', price: p.price * 6.0, selected: _variantId == '2kg', onTap: () => setState(() { _variantId='2kg'; _variantName='2kg'; _mult=6.0; })),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$_qty',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                            IconButton(
                              onPressed: () => setState(() => _qty++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: p.isInStock ? () => _addToCart(p) : null,
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text('Add to Cart'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
