import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/order/order_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserAsync = ref.watch(authStateProvider);
    final ordersAsync = ref.watch(myOrdersProvider);

    final pendingCount = ordersAsync.maybeWhen(
      data: (orders) => orders.where((o) => o.status == 'pending_payment').length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.account),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteConstants.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: authUserAsync.when(
          data: (user) {
            if (user == null) return const Center(child: Text('Not logged in'));

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
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Center(
                          child: Text(
                            user.initials,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName.isEmpty ? 'Customer' : user.displayName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user.email.isEmpty ? 'Guest account' : user.email,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (user.isAdmin)
                        TextButton(
                          onPressed: () => context.push(RouteConstants.adminDashboard),
                          child: const Text('Admin'),
                        ),
                    ],
                  ),
                ),
                if (pendingCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingLG),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$pendingCount order(s) pending payment. Open Orders to track.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(RouteConstants.orders),
                          child: const Text('Orders'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.myAddresses,
                  onTap: () => context.push(RouteConstants.addresses),
                ),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.headset_mic_outlined,
                  title: AppStrings.support,
                  onTap: () => context.push(RouteConstants.support),
                ),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.logout,
                  title: AppStrings.signOut,
                  onTap: () => ref.read(authControllerProvider.notifier).signOut(),
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

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
