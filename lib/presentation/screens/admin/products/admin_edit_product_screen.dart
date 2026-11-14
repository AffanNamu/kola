import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/remote/firestore/admin_audit_firestore.dart';
import '../../../providers/product/product_provider.dart';
import '../../../widgets/common/app_network_image.dart';

class AdminEditProductScreen extends ConsumerStatefulWidget {
  const AdminEditProductScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<AdminEditProductScreen> createState() =>
      _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends ConsumerState<AdminEditProductScreen> {
  bool _saving = false;

  Future<void> _toggle(dynamic p, String field, bool newValue) async {
    setState(() => _saving = true);
    try {
      final updated = p.copyWith(
        isAvailable: field == 'isAvailable' ? newValue : p.isAvailable,
        isFeatured: field == 'isFeatured' ? newValue : p.isFeatured,
        isNewArrival: field == 'isNewArrival' ? newValue : p.isNewArrival,
        isBestSeller: field == 'isBestSeller' ? newValue : p.isBestSeller,
      );
      final repo = ref.read(productRepositoryProvider);
      final failure = await repo.update(updated);
      if (failure != null) throw Exception(failure.message);
      await const AdminAuditFirestore().log(action: 'product_flags_changed', targetUid: p.id, details: {'field': field, 'value': newValue});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String productId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This will hide the product from customers.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final failure = await repo.softDelete(productId);
      if (failure != null) throw Exception(failure.message);
      await const AdminAuditFirestore().log(action: 'product_soft_deleted', targetUid: productId);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.editProduct),
        actions: [
          IconButton(
            onPressed: _saving ? null : () => _delete(widget.productId),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
      body: SafeArea(
        child: productAsync.when(
          data: (p) {
            if (p == null) return const Center(child: Text('Product not found'));
            return ListView(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        child: AppNetworkImage(
                          url: p.thumbnailUrl,
                          width: 72,
                          height: 72,
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SKU: ${p.sku.isEmpty ? '—' : p.sku} • Stock: ${p.stock}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (_saving)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SwitchTile(
                  title: 'Available',
                  value: p.isAvailable,
                  onChanged: _saving ? null : (v) => _toggle(p, 'isAvailable', v),
                ),
                const SizedBox(height: 10),
                _SwitchTile(
                  title: 'Featured',
                  value: p.isFeatured,
                  onChanged: _saving ? null : (v) => _toggle(p, 'isFeatured', v),
                ),
                const SizedBox(height: 10),
                _SwitchTile(
                  title: 'New Arrival',
                  value: p.isNewArrival,
                  onChanged: _saving ? null : (v) => _toggle(p, 'isNewArrival', v),
                ),
                const SizedBox(height: 10),
                _SwitchTile(
                  title: 'Best Seller',
                  value: p.isBestSeller,
                  onChanged: _saving ? null : (v) => _toggle(p, 'isBestSeller', v),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    'Next batch: edit price, stock, description, category; manage variants (250g/500g/1kg).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
