import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/order_constants.dart';
import '../../../providers/order/order_provider.dart';
import '../../../providers/payment/payment_provider.dart';

class AdminOrderDetailScreen extends ConsumerStatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends ConsumerState<AdminOrderDetailScreen> {
  final _tracking = TextEditingController();
  final _courier = TextEditingController();
  final _paymentId = TextEditingController();
  String _status = OrderConstants.processing;
  bool _saving = false;

  @override
  void dispose() {
    _tracking.dispose();
    _courier.dispose();
    _paymentId.dispose();
    super.dispose();
  }

  Future<void> _saveStatus() async {
    setState(() => _saving = true);
    try {
      await FirebaseFunctions.instance.httpsCallable('updateOrderFulfilment').call({
        'orderId': widget.orderId,
        'status': _status,
        'trackingNumber': _tracking.text.trim(),
        'courierName': _courier.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Admin Order Detail')),
      body: SafeArea(
        child: ordersAsync.when(
          data: (orders) {
            final o = orders.where((x) => x.id == widget.orderId).firstOrNull;
            if (o == null) return const Center(child: Text('Order not found'));

            if (_paymentId.text.isEmpty && (o.paymentId ?? '').isNotEmpty) {
              _paymentId.text = o.paymentId!;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.orderNumber,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                )),
                        const SizedBox(height: 6),
                        Text('User: ${o.userId}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                )),
                        const SizedBox(height: 6),
                        Text('Current status: ${o.status}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                )),
                        const SizedBox(height: 6),
                        Text('PaymentId: ${o.paymentId ?? '—'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Update Status',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                )),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _status,
                          items: const [
                            DropdownMenuItem(value: OrderConstants.pendingPayment, child: Text('Pending Payment')),
                            DropdownMenuItem(value: OrderConstants.paid, child: Text('Paid')),
                            DropdownMenuItem(value: OrderConstants.confirmed, child: Text('Confirmed')),
                            DropdownMenuItem(value: OrderConstants.processing, child: Text('Processing')),
                            DropdownMenuItem(value: OrderConstants.packed, child: Text('Packed')),
                            DropdownMenuItem(value: OrderConstants.shipped, child: Text('Shipped')),
                            DropdownMenuItem(value: OrderConstants.delivered, child: Text('Delivered')),
                            DropdownMenuItem(value: OrderConstants.cancelled, child: Text('Cancelled')),
                            DropdownMenuItem(value: OrderConstants.refunded, child: Text('Refunded')),
                          ],
                          onChanged: _saving ? null : (v) => setState(() => _status = v ?? _status),
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.timeline), labelText: 'Status'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _courier,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.local_shipping_outlined), labelText: 'Courier Name (optional)'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tracking,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.confirmation_number_outlined), labelText: 'Tracking Number (optional)'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveStatus,
                            child: _saving
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Save Status'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                )),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _paymentId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.payment_outlined),
                            labelText: 'Payment ID (Firestore)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _markPaid,
                            icon: const Icon(Icons.verified_outlined),
                            label: const Text('Mark as Paid'),
                          ),
                        ),
                      ],
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
