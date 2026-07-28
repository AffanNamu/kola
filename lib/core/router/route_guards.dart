import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../data/models/user/user_model.dart';

class RouteGuards {
  RouteGuards._();

  static const List<String> _publicRoutes = [
    RouteConstants.splash,
    RouteConstants.onboarding,
    RouteConstants.login,
    RouteConstants.register,
    RouteConstants.forgotPassword,
  ];

  static const List<String> _adminRoutes = [
    RouteConstants.adminDashboard,
  ];

  static const List<String> _authRequiredRoutes = [
    RouteConstants.cart,
    RouteConstants.checkout,
    RouteConstants.orders,
    RouteConstants.account,
    RouteConstants.wishlist,
    RouteConstants.profile,
    RouteConstants.notifications,
    RouteConstants.support,
  ];

  static String? redirect(AsyncValue<UserModel?> authState, GoRouterState state) {
    final currentPath = state.matchedLocation;

    return authState.when(
      data: (user) {
        final isLoggedIn = user != null;
        final isAdmin = user?.role == 'admin';
        final isPublicRoute = _publicRoutes.any(
          (route) => currentPath.startsWith(route),
        );
        final isAdminRoute = _adminRoutes.any(
          (route) => currentPath.startsWith(route),
        );
        final isSplash = currentPath == RouteConstants.splash;

        if (isSplash) return null;

        if (isLoggedIn && isPublicRoute && !isSplash) {
          if (isAdmin) return RouteConstants.adminDashboard;
          return RouteConstants.home;
        }

        if (!isLoggedIn) {
          final needsAuth = _authRequiredRoutes.any(
            (route) => currentPath.startsWith(route),
          );
          if (needsAuth) return RouteConstants.login;
          if (isAdminRoute) return RouteConstants.login;
        }

        if (isLoggedIn && isAdminRoute && !isAdmin) {
          return RouteConstants.home;
        }

        return null;
      },
      loading: () => null,
      error: (_, __) => RouteConstants.login,
    );
  }
}
