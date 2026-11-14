import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../providers/analytics/admin_analytics_provider.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Reports',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(RouteConstants.adminRecomputeAnalytics),
            child: const Text('Recompute'),
          ),
        ],
      ),
      body: SafeArea(
        child: statsAsync.when(
          data: (s) {
            return ListView(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              children: [
                _StatsRow(
                  a: _StatCardData(
                    title: 'Revenue (30d)',
                    value: CurrencyFormatter.usd(s.revenue30d),
                    icon: Icons.payments_outlined,
                  ),
                  b: _StatCardData(
                    title: 'Orders (30d)',
                    value: s.orders30d.toString(),
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                _StatsRow(
                  a: _StatCardData(
                    title: 'Customers',
                    value: s.customers.toString(),
                    icon: Icons.people_outline,
                  ),
                  b: _StatCardData(
                    title: 'Products',
                    value: s.products.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product revenue leaderboard',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Paid orders only • lifetime totals',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('productSales')
                            .orderBy('revenue', descending: true).limit(10).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return Text('Product analytics unavailable: ${snapshot.error}');
                          if (!snapshot.hasData) return const LinearProgressIndicator();
                          if (snapshot.data!.docs.isEmpty) return const Text('No paid product sales recorded yet.');
                          return Column(children: snapshot.data!.docs.map((doc) {
                            final data = doc.data();
                            final name = (data['productName'] ?? doc.id).toString();
                            final units = (data['unitsSold'] as num?)?.toInt() ?? 0;
                            final revenue = (data['revenue'] as num?)?.toDouble() ?? 0;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('$units units sold'),
                              trailing: Text(CurrencyFormatter.usd(revenue),
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                            );
                          }).toList());
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Products (30d)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (s.topProducts.isEmpty)
                        Text(
                          'No sales data yet.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        )
                      else
                        ...s.topProducts.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '${p.qty} sold',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            )),
                      const SizedBox(height: 10),
                      Text(
                        'Last updated: ${s.updatedAtIso.isEmpty ? '—' : s.updatedAtIso}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.a, required this.b});
  final _StatCardData a;
  final _StatCardData b;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(data: a)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(data: b)),
      ],
    );
  }
}

class _StatCardData {
  _StatCardData({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});
  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(data.icon, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
          ),
        ],
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
