import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../providers/payment/admin_payments_provider.dart';
import '../../../providers/payment/payment_provider.dart';

class AdminPaymentDetailScreen extends ConsumerWidget {
  const AdminPaymentDetailScreen({super.key, required this.paymentId});
  final String paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(paymentByIdProvider(paymentId));
    final verifyState = ref.watch(paymentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment Detail')),
      body: SafeArea(
        child: paymentAsync.when(
          data: (p) {
            if (p == null) return const Center(child: Text('Payment not found'));

            final rawSize = p.gatewayResponse.length;

            return Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
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
                    Text(
                      p.gateway.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText('Payment ID: ${p.id}'),
                    const SizedBox(height: 8),
                    SelectableText('Order ID: ${p.orderId}'),
                    const SizedBox(height: 8),
                    SelectableText('Reference: ${p.reference}'),
                    const SizedBox(height: 8),
                    Text('Status: ${p.status}'),
                    const SizedBox(height: 6),
                    Text(
                      'Gateway response fields: $rawSize',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: verifyState.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(paymentControllerProvider.notifier)
                                    .verifyPaymentViaSupabase(
                                      paymentId: p.id,
                                      gateway: p.gateway,
                                      referenceOrTransactionId: p.reference,
                                      orderId: p.orderId,
                                    );
                              },
                        icon: const Icon(Icons.verified_outlined),
                        label: Text(verifyState.isLoading ? 'Verifying...' : 'Verify via Supabase'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: verifyState.isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(paymentControllerProvider.notifier)
                                    .adminMarkPaid(orderId: p.orderId, paymentId: p.id);
                              },
                        child: const Text('Mark Paid (Manual)'),
                      ),
                    ),
                  ],
                ),
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
