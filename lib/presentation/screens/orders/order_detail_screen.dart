import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/order/order_provider.dart';
import '../../providers/payment/payment_order_provider.dart';
import '../../providers/payment/payment_provider.dart';
import 'order_payment_help_card.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);
    final paymentsAsync = ref.watch(paymentsForOrderProvider(orderId));
    final verifyState = ref.watch(paymentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Detail')),
      body: SafeArea(
        child: ordersAsync.when(
          data: (orders) {
            final o = orders.where((x) => x.id == orderId).firstOrNull;
            if (o == null) return const Center(child: Text('Order not found'));

            return ListView(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.orderNumber,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Status: ${o.status.replaceAll('_', ' ')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total: ${CurrencyFormatter.usd(o.total)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const OrderPaymentHelpCard(),
                const SizedBox(height: 12),
                _Card(
                  child: paymentsAsync.when(
                    data: (payments) {
                      final latest = payments.isEmpty ? null : payments.first;
                      if (latest == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No payment record yet. Tap below to choose a payment method.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  final uri = Uri(
                                    path: '${RouteConstants.checkout}/payment',
                                    queryParameters: {
                                      'orderId': o.id,
                                      'amount': o.total.toStringAsFixed(2),
                                    },
                                  );
                                  context.push(uri.toString());
                                },
                                child: const Text('Pay Now'),
                              ),
                            ),
                          ],
                        );
                      }

                      final isSuccess = latest.status == 'success';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gateway: ${latest.gateway}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText('Reference: ${latest.reference}'),
                          const SizedBox(height: 6),
                          Text(
                            'Status: ${latest.status}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSuccess ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (!isSuccess) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: verifyState.isLoading
                                    ? null
                                    : () async {
                                        await ref
                                            .read(paymentControllerProvider.notifier)
                                            .verifyPaymentViaSupabase(
                                              paymentId: latest.id,
                                              gateway: latest.gateway,
                                              referenceOrTransactionId: latest.reference,
                                              orderId: o.id,
                                            );
                                      },
                                icon: const Icon(Icons.verified_outlined),
                                label: Text(
                                  verifyState.isLoading ? 'Verifying...' : 'Verify Payment',
                                ),
                              ),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: const Text('Payment verified successfully.'),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Payment error: $e'),
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Items',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              )),
                      const SizedBox(height: 10),
                      ...o.items.map((it) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(child: Text('${it.productName} x${it.quantity}')),
                                Text(CurrencyFormatter.usd(it.total)),
                              ],
                            ),
                          )),
                    ],
                  ),
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

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
