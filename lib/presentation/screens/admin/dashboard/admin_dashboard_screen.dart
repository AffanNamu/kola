import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/route_constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          children: [
            _Grid(items: [
              _Item('Products', Icons.inventory_2_outlined,
                  () => context.push('/admin/products')),
              _Item('Categories', Icons.category_outlined,
                  () => context.push('/admin/categories')),
              _Item('Banners', Icons.photo_outlined,
                  () => context.push('/admin/banners')),
              _Item('Orders', Icons.receipt_long_outlined,
                  () => context.push('/admin/orders')),
              _Item('Payments', Icons.payment_outlined,
                  () => context.push(RouteConstants.adminPayments)),
              _Item('Reports', Icons.bar_chart_outlined,
                  () => context.push(RouteConstants.adminReports)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Item {
  _Item(this.title, this.icon, this.onTap);
  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _Grid extends StatelessWidget {
  const _Grid({required this.items});
  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        return InkWell(
          onTap: it.onTap,
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Icon(it.icon, color: AppColors.primary),
                ),
                const Spacer(),
                Text(
                  it.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
