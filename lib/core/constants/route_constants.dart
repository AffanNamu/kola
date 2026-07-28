class RouteConstants {
  RouteConstants._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';

  static const String home = '/home';
  static const String categories = '/categories';
  static const String shop = '/shop';
  static const String orders = '/orders';
  static const String account = '/account';

  static const String search = '/search';
  static const String searchResults = '/search/results';

  static const String cart = '/cart';

  static const String checkout = '/checkout';
  static const String paymentMethod = '/checkout/payment';
  static const String orderSuccess = '/checkout/success';

  static const String wishlist = '/wishlist';
  static const String notifications = '/notifications';
  static const String support = '/support';
  static const String createTicket = '/support/create';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminAddProduct = '/admin/products/add';
  static const String adminCategories = '/admin/categories';
  static const String adminAddCategory = '/admin/categories/add';
  static const String adminOrders = '/admin/orders';
  static const String adminBanners = '/admin/banners';
  static const String adminAddBanner = '/admin/banners/add';
  static const String adminReports = '/admin/reports';
  static const String adminRecomputeAnalytics = '/admin/reports/recompute';

  static const String adminPayments = '/admin/payments';
  static const String adminPaymentDetail = '/admin/payments/:paymentId';

  static const String adminSettings = '/admin/settings';
}
