import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/banner/banner_provider.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/category/category_provider.dart';
import '../../providers/product/product_provider.dart';
import '../../widgets/banner/banner_carousel.dart';
import '../../widgets/category/category_card.dart';
import '../../widgets/common/app_network_image.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(featuredProductsProvider.notifier).load();
      ref.read(newArrivalsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredProductsProvider);
    final newArrivalsState = ref.watch(newArrivalsProvider);
    final cartCountAsync = ref.watch(cartCountProvider);
    final bannersAsync = ref.watch(activeBannersProvider);
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    final cartCount = cartCountAsync.maybeWhen(data: (v) => v, orElse: () => 0);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        children: [
          _Header(
            cartCount: cartCount,
            onSearch: () => context.push(RouteConstants.search),
            onCart: () => context.push(RouteConstants.cart),
          ),
          const SizedBox(height: 14),

          bannersAsync.when(
            data: (banners) {
              if (banners.isEmpty) {
                return _FallbackHero(onShopNow: () => context.go(RouteConstants.shop));
              }
              return BannerCarousel(
                banners: banners,
                onTapBanner: (_) => context.go(RouteConstants.shop),
              );
            },
            loading: () => _FallbackHero(onShopNow: () => context.go(RouteConstants.shop)),
            error: (_, __) => _FallbackHero(onShopNow: () => context.go(RouteConstants.shop)),
          ),

          const SizedBox(height: 16),
          const _FeatureRow(),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.shopByCategory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(RouteConstants.categories),
                child: Text(
                  AppStrings.viewAll,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          categoriesAsync.when(
            data: (cats) {
              if (cats.isEmpty) {
                return const _InlineError(message: 'No categories yet. Add in Admin.');
              }
              return SizedBox(
                height: 124,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length.clamp(0, 10),
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    final img = c.imageUrl.isNotEmpty ? c.imageUrl : c.iconUrl;

                    return CategoryCard(
                      name: c.name,
                      imageUrl: img,
                      onTap: () {
                        final uri = Uri(
                          path: RouteConstants.shop,
                          queryParameters: {
                            'categoryId': c.id,
                            'categoryName': c.name,
                          },
                        );
                        context.go(uri.toString());
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const _LoadingCategoryRow(),
            error: (e, _) => _InlineError(message: 'Error loading categories: $e'),
          ),

          const SizedBox(height: 18),
          _SectionTitle(
            title: AppStrings.featuredProducts,
            onViewAll: () => context.go(RouteConstants.shop),
          ),
          const SizedBox(height: 12),
          featuredState.when(
            initial: () => const _LoadingRow(),
            loading: () => const _LoadingRow(),
            error: (m) => _InlineError(message: m),
            loaded: (products) => _ProductHorizontalList(products: products),
          ),

          const SizedBox(height: 20),
          _SectionTitle(
            title: AppStrings.newArrivals,
            onViewAll: () => context.go(RouteConstants.shop),
          ),
          const SizedBox(height: 12),
          newArrivalsState.when(
            initial: () => const _LoadingRow(),
            loading: () => const _LoadingRow(),
            error: (m) => _InlineError(message: m),
            loaded: (products) => _ProductHorizontalList(products: products),
          ),

          const SizedBox(height: 22),
          _WhyChooseCard(onTap: () => context.go(RouteConstants.shop)),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onSearch,
    required this.onCart,
    required this.cartCount,
  });

  final VoidCallback onSearch;
  final VoidCallback onCart;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Icon(Icons.eco, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
              ),
              Text(
                AppStrings.appTagline,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        IconButton(onPressed: onSearch, icon: const Icon(Icons.search)),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onCart,
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            if (cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---- rest unchanged minimal
class _FallbackHero extends StatelessWidget {
  const _FallbackHero({required this.onShopNow});
  final VoidCallback onShopNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A16), Color(0xFF2D5A27)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.heroBannerTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.heroBannerSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onShopNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 44),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(AppStrings.shopNow),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Icon(Icons.spa, color: Colors.white, size: 48),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _FeatureItem(icon: Icons.eco_outlined, title: '100% Natural', subtitle: 'Pure & Safe'),
          _FeatureItem(icon: Icons.public, title: 'Worldwide', subtitle: 'Shipping'),
          _FeatureItem(icon: Icons.verified_user_outlined, title: 'Secure', subtitle: 'Payment'),
          _FeatureItem(icon: Icons.headset_mic_outlined, title: '24/7', subtitle: 'Support'),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LoadingCategoryRow extends StatelessWidget {
  const _LoadingCategoryRow();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => Column(
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                border: Border.all(color: AppColors.borderLight),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: AppColors.borderLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onViewAll});
  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            AppStrings.viewAll,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ],
    );
  }
}

class _ProductHorizontalList extends ConsumerWidget {
  const _ProductHorizontalList({required this.products});
  final List products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const _InlineError(message: 'No products yet. Add products in Admin.');
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = products[i];
          return InkWell(
            onTap: () => context.push('/products/${p.id}'),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            child: Container(
              width: 170,
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    child: AppNetworkImage(
                      url: p.thumbnailUrl,
                      width: double.infinity,
                      height: 120,
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${p.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () async {
                        await ref.read(cartControllerProvider.notifier).addToCart(
                              productId: p.id,
                              name: p.name,
                              image: p.thumbnailUrl,
                              price: p.price,
                              quantity: 1,
                              variantId: 'default',
                              variantName: '250g',
                              sku: p.sku,
                              maxStock: p.stock,
                            );
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WhyChooseCard extends StatelessWidget {
  const _WhyChooseCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5EA),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
              ),
              child: const Icon(Icons.verified, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.whyChooseKolanut,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.whyChooseDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 170,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            border: Border.all(color: AppColors.borderLight),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
