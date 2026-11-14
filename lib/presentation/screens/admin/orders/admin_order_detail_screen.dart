import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../providers/order/order_provider.dart';

class AdminOrderDetailScreen extends ConsumerStatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends ConsumerState<AdminOrderDetailScreen> {
  final _tracking = TextEditingController();
  final _courier = TextEditingController();
  final _note = TextEditingController();
  String? _nextStatus;
  bool _saving = false;

  @override
  void dispose() {
    _tracking.dispose();
    _courier.dispose();
    _note.dispose();
    super.dispose();
  }

  List<String> _allowedNext(String status) {
    switch (status) {
      case 'paid': return ['confirmed'];
      case 'confirmed': return ['processing'];
      case 'processing': return ['packed'];
      case 'packed': return ['shipped'];
      case 'shipped': return ['delivered'];
      case 'delivered': return ['refunded'];
      default: return [];
    }
  }

  Future<void> _saveStatus() async {
    if (_nextStatus == null) return;
    if (_nextStatus == 'shipped' && (_tracking.text.trim().isEmpty || _courier.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the courier and tracking number before shipping.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFunctions.instance.httpsCallable('updateOrderFulfilment').call({
        'orderId': widget.orderId,
        'status': _nextStatus,
        'trackingNumber': _tracking.text.trim(),
        'courierName': _courier.text.trim(),
        'note': _note.text.trim(),
      });
      if (!mounted) return;
      setState(() { _nextStatus = null; _note.clear(); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order fulfilment updated and recorded.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order fulfilment')),
      body: SafeArea(child: ordersAsync.when(
        data: (orders) {
          final order = orders.where((item) => item.id == widget.orderId).firstOrNull;
          if (order == null) return const Center(child: Text('Order not found'));
          final next = _allowedNext(order.status);
          final selected = next.contains(_nextStatus) ? _nextStatus : null;
          return ListView(padding: const EdgeInsets.all(AppSizes.paddingMD), children: [
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              _InfoRow('Order ID', order.id),
              _InfoRow('Customer UID', order.userId),
              _InfoRow('Current status', order.status.toUpperCase()),
              _InfoRow('Payment', order.paymentId ?? 'No payment linked'),
              _InfoRow('Total', '${order.total.toStringAsFixed(2)} ${order.metadata['currency'] ?? 'USD'}'),
              _InfoRow('Courier', order.courierName.isEmpty ? 'Not assigned' : order.courierName),
              _InfoRow('Tracking', order.trackingNumber.isEmpty ? 'Not available' : order.trackingNumber),
            ])),
            const SizedBox(height: 12),
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...order.items.map((item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Qty: ${item.quantity} • ${item.variantName.isEmpty ? 'Standard' : item.variantName}'),
                trailing: Text((item.price * item.quantity).toStringAsFixed(2)),
              )),
            ])),
            const SizedBox(height: 12),
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Next fulfilment step', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (next.isEmpty)
                Text(order.status == 'pending_payment' ? 'Waiting for verified payment before fulfilment.' : 'No further fulfilment transition is available for this order.'),
              if (next.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: selected,
                  decoration: const InputDecoration(labelText: 'Move order to', border: OutlineInputBorder()),
                  items: next.map((status) => DropdownMenuItem(value: status, child: Text(status.replaceAll('_', ' ').toUpperCase()))).toList(),
                  onChanged: _saving ? null : (value) => setState(() => _nextStatus = value),
                ),
                const SizedBox(height: 12),
                TextField(controller: _courier, decoration: const InputDecoration(labelText: 'Courier / delivery partner', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _tracking, decoration: const InputDecoration(labelText: 'Tracking number', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _note, maxLines: 2, decoration: const InputDecoration(labelText: 'Internal fulfilment note (optional)', border: OutlineInputBorder())),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                  onPressed: _saving || selected == null ? null : _saveStatus,
                  child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save fulfilment update'),
                )),
              ],
            ])),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load order: $error')),
      )),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.paddingLG),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusXL), border: Border.all(color: AppColors.borderLight)),
    child: child,
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 112, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
