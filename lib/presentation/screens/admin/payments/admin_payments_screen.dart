import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../providers/payment/admin_payments_provider.dart';

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  ConsumerState<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(adminPaymentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Payments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: SafeArea(
        child: paymentsAsync.when(
          data: (payments) {
            List list = [...payments];

            if (_filter != 'all') {
              list = list.where((p) => p.status == _filter).toList();
            }

            list.sort((a, b) {
              int rank(String s) => s == 'pending' ? 0 : (s == 'failed' ? 1 : 2);
              final r = rank(a.status).compareTo(rank(b.status));
              if (r != 0) return r;
              return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
            });

            return Column(
              children: [
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                  child: Row(
                    children: [
                      _Chip(text: 'All', active: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                      const SizedBox(width: 8),
                      _Chip(text: 'Pending', active: _filter == 'pending', onTap: () => setState(() => _filter = 'pending')),
                      const SizedBox(width: 8),
                      _Chip(text: 'Success', active: _filter == 'success', onTap: () => setState(() => _filter = 'success')),
                      const SizedBox(width: 8),
                      _Chip(text: 'Failed', active: _filter == 'failed', onTap: () => setState(() => _filter = 'failed')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingLG),
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.paddingLG),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: const Text('No payments in this filter.'),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSizes.paddingMD),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final p = list[i];
                            final isPending = p.status == 'pending';
                            final isSuccess = p.status == 'success';

                            Color badgeColor = AppColors.warning;
                            Color badgeBg = AppColors.warningLight;
                            String badge = 'Pending';
                            if (isSuccess) {
                              badgeColor = AppColors.success;
                              badgeBg = AppColors.successLight;
                              badge = 'Success';
                            } else if (!isPending) {
                              badgeColor = AppColors.error;
                              badgeBg = AppColors.errorLight;
                              badge = 'Failed';
                            }

                            return InkWell(
                              onTap: () => context.push('/admin/payments/${p.id}'),
                              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                              child: Container(
                                padding: const EdgeInsets.all(AppSizes.paddingLG),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySurface,
                                            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                                            border: Border.all(color: AppColors.borderLight),
                                          ),
                                          child: const Icon(Icons.payment_outlined, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.gateway.toUpperCase(),
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Order: ${p.orderId}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: AppColors.textSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: badgeBg,
                                            borderRadius: BorderRadius.circular(99),
                                            border: Border.all(color: AppColors.borderLight),
                                          ),
                                          child: Text(
                                            badge,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: badgeColor,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Ref: ${p.reference}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.usd(p.amount),
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.active, required this.onTap});
  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderLight,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}
