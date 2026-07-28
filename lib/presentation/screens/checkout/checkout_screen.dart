import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/checkout/checkout_provider.dart';
import '../../widgets/cart/cart_item_tile.dart';
import '../../widgets/common/app_empty_widget.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartItemsStreamProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: cartAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const AppEmptyWidget(
                title: 'Cart is empty',
                subtitle: 'Add items to your cart to checkout.',
                icon: Icons.shopping_cart_outlined,
              );
            }

            final subtotal = items.fold<double>(0, (sum, x) => sum + x.total);
            final shipping = 0.0;
            final total = subtotal + shipping;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
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
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...items.map((x) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CartItemTile(item: x),
                            )),
                        const Divider(),
                        const SizedBox(height: 8),
                        _Row(label: 'Subtotal', value: CurrencyFormatter.usd(subtotal)),
                        const SizedBox(height: 6),
                        _Row(label: 'Shipping', value: CurrencyFormatter.usd(shipping)),
                        const SizedBox(height: 10),
                        _Row(
                          label: 'Total',
                          value: CurrencyFormatter.usd(total),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: checkoutState.isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(checkoutControllerProvider.notifier)
                                  .createOrderFromCart();

                              final res = ref.read(checkoutControllerProvider);
                              res.when(
                                data: (orderId) {
                                  if (orderId == null || orderId.isEmpty) return;

                                  final uri = Uri(
                                    path: '${RouteConstants.checkout}/payment',
                                    queryParameters: {
                                      'orderId': orderId,
                                      'amount': total.toStringAsFixed(2),
                                    },
                                  );

                                  context.push(uri.toString());
                                },
                                loading: () {},
                                error: (e, _) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                },
                              );
                            },
                      child: checkoutState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Proceed to Payment'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bootstrap mode: payment verification is manual.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
        );
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Text(value, style: style),
      ],
    );
  }
}
