import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/cart/cart_provider.dart';
import '../common/app_network_image.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
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
              url: item.productImage,
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
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                if ((item.variantName as String).isNotEmpty)
                  Text(
                    item.variantName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.usd(item.price),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => ref
                      .read(cartControllerProvider.notifier)
                      .setQuantity(item.id, item.quantity - 1),
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '${item.quantity}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                IconButton(
                  onPressed: () => ref
                      .read(cartControllerProvider.notifier)
                      .setQuantity(item.id, item.quantity + 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
