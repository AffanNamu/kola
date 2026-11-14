import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/payment/payment_provider.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  bool _loading = false;
  String _paymentId = '';
  String _gateway = '';
  String _ref = '';

  String _genRef() =>
      'KOLA-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

  Future<void> _createPendingPayment(String gateway) async {
    final uri = GoRouterState.of(context).uri;
    final orderId = uri.queryParameters['orderId'];
    final amountStr = uri.queryParameters['amount'];

    if (orderId == null || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing orderId')),
      );
      return;
    }

    final amount = double.tryParse(amountStr ?? '') ?? 0.0;
    final reference = _genRef();

    setState(() {
      _loading = true;
      _paymentId = '';
      _gateway = gateway;
      _ref = reference;
    });

    try {
      final paymentId = await ref
          .read(paymentControllerProvider.notifier)
          .createPendingPaymentForOrder(
            orderId: orderId,
            gateway: gateway,
            reference: reference,
          );

      if (!mounted) return;
      setState(() => _paymentId = paymentId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment created. ID: $paymentId')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    final uri = GoRouterState.of(context).uri;
    final orderId = uri.queryParameters['orderId'] ?? '';
    if (_paymentId.isEmpty || _gateway.isEmpty || _ref.isEmpty) return;

    await ref.read(paymentControllerProvider.notifier).verifyPaymentWithGateway(
          paymentId: _paymentId,
        );

    final st = ref.read(paymentControllerProvider);
    st.whenOrNull(
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verify failed: $e')),
        );
      },
      data: (_) {
        context.go('${RouteConstants.checkout}/success?orderId=$orderId');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment Method')),
      body: SafeArea(
        child: Padding(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Payment Gateway',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create payment securely and verify it with the gateway.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_loading || paymentState.isLoading)
                        ? null
                        : () => _createPendingPayment('paystack'),
                    child: const Text('Pay with Paystack'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: (_loading || paymentState.isLoading)
                        ? null
                        : () => _createPendingPayment('flutterwave'),
                    child: const Text('Pay with Flutterwave'),
                  ),
                ),
                const SizedBox(height: 18),
                if (_paymentId.isNotEmpty) ...[
                  Text('Payment ID:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  SelectableText(_paymentId),
                  const SizedBox(height: 10),
                  Text('Reference:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  SelectableText(_ref),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: paymentState.isLoading ? null : _verify,
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(paymentState.isLoading ? 'Verifying...' : 'Verify Payment Now'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
