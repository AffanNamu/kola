import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/cart/cart_provider.dart';
import '../../widgets/cart/cart_item_tile.dart';
import '../../widgets/cart/cart_summary.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartItemsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.myCart),
        actions: [
          TextButton(
            onPressed: () => ref.read(cartControllerProvider.notifier).clear(),
            child: const Text('Clear'),
          ),
        ],
      ),
      body: SafeArea(
        child: cartAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined,
                          color: AppColors.textTertiary, size: 54),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.cartEmpty,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.cartEmptyDesc,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go(RouteConstants.shop),
                        child: const Text(AppStrings.continueShopping),
                      )
                    ],
                  ),
                ),
              );
            }

            final subtotal =
                items.fold<double>(0, (sum, x) => sum + x.total);
            final shipping = 0.0;
            final total = subtotal + shipping;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => CartItemTile(item: items[i]),
                  ),
                ),
                CartSummary(
                  subtotal: subtotal,
                  shipping: shipping,
                  total: total,
                  onCheckout: () => context.push(RouteConstants.checkout),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
