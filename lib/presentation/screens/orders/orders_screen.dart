import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/order/order_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
            Tab(text: 'Returned'),
          ],
        ),
      ),
      body: SafeArea(
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
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
                    child: const Text('No orders yet.'),
                  ),
                ),
              );
            }

            return TabBarView(
              controller: _tab,
              children: List.generate(6, (index) {
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final o = orders[i];
                    final isPending = o.status == 'pending_payment';

                    return InkWell(
                      onTap: () => context.push('/orders/${o.id}'),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    o.orderNumber,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                _StatusBadge(status: o.status),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    CurrencyFormatter.usd(o.total),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                Text(
                                  '${o.totalItems} items',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                            if (isPending) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color c = AppColors.primary;
    Color bg = AppColors.primarySurface;

    switch (status) {
      case 'pending_payment':
        c = AppColors.warning;
        bg = AppColors.warningLight;
        break;
      case 'paid':
        c = AppColors.info;
        bg = AppColors.infoLight;
        break;
      case 'shipped':
        c = AppColors.info;
        bg = AppColors.infoLight;
        break;
      case 'delivered':
        c = AppColors.success;
        bg = AppColors.successLight;
        break;
      case 'cancelled':
        c = AppColors.error;
        bg = AppColors.errorLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: c,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}
