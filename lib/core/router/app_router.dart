import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/route_constants.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/verify_email_screen.dart';

import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/home/home_tab.dart';

import '../../presentation/screens/categories/categories_screen.dart';

import '../../presentation/screens/product/product_list_screen.dart';
import '../../presentation/screens/product/product_detail_screen.dart';
import '../../presentation/screens/product/product_review_screen.dart';

import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/search/search_results_screen.dart';

import '../../presentation/screens/cart/cart_screen.dart';

import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/checkout/payment_method_screen.dart';
import '../../presentation/screens/checkout/order_success_screen.dart';

import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/orders/order_detail_screen.dart';
import '../../presentation/screens/orders/order_tracking_screen.dart';

import '../../presentation/screens/wishlist/wishlist_screen.dart';

import '../../presentation/screens/profile/profile_screen.dart';

import '../../presentation/screens/notifications/notifications_screen.dart';

import '../../presentation/screens/support/support_screen.dart';
import '../../presentation/screens/support/create_ticket_screen.dart';
import '../../presentation/screens/support/ticket_detail_screen.dart';

import '../../presentation/screens/admin/dashboard/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/customers/admin_customer_detail_screen.dart';
import '../../presentation/screens/admin/inventory/admin_inventory_screen.dart';
import '../../presentation/screens/admin/coupons/admin_coupons_screen.dart';
import '../../presentation/screens/admin/notifications/admin_notifications_screen.dart';

import '../../presentation/screens/admin/products/admin_products_screen.dart';
import '../../presentation/screens/admin/products/admin_add_product_screen.dart';
import '../../presentation/screens/admin/products/admin_edit_product_screen.dart';

import '../../presentation/screens/admin/categories/admin_categories_screen.dart';
import '../../presentation/screens/admin/categories/admin_add_category_screen.dart';

import '../../presentation/screens/admin/orders/admin_orders_screen.dart';
import '../../presentation/screens/admin/orders/admin_order_detail_screen.dart';

import '../../presentation/screens/admin/banners/admin_banners_screen.dart';
import '../../presentation/screens/admin/banners/admin_add_banner_screen.dart';

import '../../presentation/screens/admin/reports/admin_reports_screen.dart';
import '../../presentation/screens/admin/reports/admin_recompute_analytics_screen.dart';

import '../../presentation/screens/admin/payments/admin_payments_screen.dart';
import '../../presentation/screens/admin/payments/admin_payment_detail_screen.dart';

import '../../presentation/screens/admin/reviews/admin_reviews_screen.dart';

import '../../presentation/providers/auth/auth_provider.dart';
import 'route_guards.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    redirect: (context, state) => RouteGuards.redirect(authState, state),
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        pageBuilder: (c, s) => _fadeTransition(
          state: s,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.register,
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.verifyEmail,
        builder: (_, __) => const VerifyEmailScreen(),
      ),

      // Main shell
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.home,
            builder: (_, __) => const HomeTab(),
          ),
          GoRoute(
            path: RouteConstants.categories,
            builder: (_, __) => const CategoriesScreen(),
          ),
          GoRoute(
            path: RouteConstants.shop,
            builder: (context, state) => ProductListScreen(
              showCategories: false,
              categoryId: state.uri.queryParameters['categoryId'],
              categoryName: state.uri.queryParameters['categoryName'],
            ),
          ),
          GoRoute(
            path: RouteConstants.orders,
            builder: (_, __) => const OrdersScreen(),
          ),
          GoRoute(
            path: RouteConstants.account,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Search
      GoRoute(
        path: RouteConstants.search,
        pageBuilder: (c, s) => _fadeTransition(
          state: s,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: RouteConstants.searchResults,
        builder: (c, s) => SearchResultsScreen(
          query: s.uri.queryParameters['q'] ?? '',
        ),
      ),

      // Cart
      GoRoute(
        path: RouteConstants.cart,
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: const CartScreen(),
        ),
      ),

      // Checkout
      GoRoute(
        path: RouteConstants.checkout,
        builder: (_, __) => const CheckoutScreen(),
        routes: [
          GoRoute(
            path: 'payment',
            builder: (_, __) => const PaymentMethodScreen(),
          ),
          GoRoute(
            path: 'success',
            builder: (c, s) => OrderSuccessScreen(
              orderId: s.uri.queryParameters['orderId'] ?? '',
            ),
          ),
        ],
      ),

      // Product
      GoRoute(
        path: '/products/:productId',
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: ProductDetailScreen(
            productId: s.pathParameters['productId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/products/:productId/reviews',
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: ProductReviewScreen(
            productId: s.pathParameters['productId']!,
          ),
        ),
      ),

      // Orders
      GoRoute(
        path: '/orders/:orderId',
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: OrderDetailScreen(orderId: s.pathParameters['orderId']!),
        ),
      ),
      GoRoute(
        path: '/orders/:orderId/tracking',
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: OrderTrackingScreen(orderId: s.pathParameters['orderId']!),
        ),
      ),

      // Wishlist
      GoRoute(
        path: RouteConstants.wishlist,
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: const WishlistScreen(),
        ),
      ),

      // Notifications
      GoRoute(
        path: RouteConstants.notifications,
        pageBuilder: (c, s) => _slideTransition(
          state: s,
          child: const NotificationsScreen(),
        ),
      ),

      // Support
      GoRoute(
        path: RouteConstants.support,
        builder: (_, __) => const SupportScreen(),
      ),
      GoRoute(
        path: RouteConstants.createTicket,
        builder: (_, __) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/support/:ticketId',
        builder: (c, s) => TicketDetailScreen(
          ticketId: s.pathParameters['ticketId']!,
        ),
      ),

      // Admin
      GoRoute(
        path: RouteConstants.adminDashboard,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/customers/:customerId',
        builder: (c, s) => AdminCustomerDetailScreen(
          customerId: s.pathParameters['customerId']!,
        ),
      ),
      GoRoute(
        path: '/admin/inventory',
        builder: (_, __) => const AdminInventoryScreen(),
      ),
      GoRoute(
        path: '/admin/coupons',
        builder: (_, __) => const AdminCouponsScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (_, __) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminProducts,
        builder: (_, __) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminAddProduct,
        builder: (_, __) => const AdminAddProductScreen(),
      ),
      GoRoute(
        path: '/admin/products/:productId/edit',
        builder: (c, s) => AdminEditProductScreen(
          productId: s.pathParameters['productId']!,
        ),
      ),
      GoRoute(
        path: RouteConstants.adminCategories,
        builder: (_, __) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminAddCategory,
        builder: (_, __) => const AdminAddCategoryScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminOrders,
        builder: (_, __) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/orders/:orderId',
        builder: (c, s) => AdminOrderDetailScreen(
          orderId: s.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: RouteConstants.adminBanners,
        builder: (_, __) => const AdminBannersScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminAddBanner,
        builder: (_, __) => const AdminAddBannerScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminReports,
        builder: (_, __) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminRecomputeAnalytics,
        builder: (_, __) => const AdminRecomputeAnalyticsScreen(),
      ),

      GoRoute(
        path: RouteConstants.adminPayments,
        builder: (_, __) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: '/admin/payments/:paymentId',
        builder: (c, s) => AdminPaymentDetailScreen(
          paymentId: s.pathParameters['paymentId']!,
        ),
      ),

      GoRoute(
        path: RouteConstants.adminReviews,
        builder: (_, __) => const AdminReviewsScreen(),
      ),
    ],
  );
}

Page<dynamic> _slideTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

Page<dynamic> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
