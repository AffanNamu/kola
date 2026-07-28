import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';

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
    '/admin',
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

  static String? redirect(AsyncValue authState, GoRouterState state) {
    final currentPath = state.matchedLocation;

    return authState.when(
      data: (user) {
        final isLoggedIn = user != null;
        final isAdmin = user?.role == 'admin';
        final isPublicRoute = _publicRoutes.any(
          (route) => currentPath.startsWith(route),
        );
        final isAdminRoute = currentPath.startsWith('/admin');
        final isSplash = currentPath == RouteConstants.splash;

        // Always allow splash
        if (isSplash) return null;

        // If logged in and trying to access auth routes, go home
        if (isLoggedIn && isPublicRoute && !isSplash) {
          if (isAdmin) return RouteConstants.adminDashboard;
          return RouteConstants.home;
        }

        // If not logged in and trying to access protected routes
        if (!isLoggedIn) {
          final needsAuth = _authRequiredRoutes.any(
            (route) => currentPath.startsWith(route),
          );
          if (needsAuth) return RouteConstants.login;

          // Block admin routes for non-logged-in users
          if (isAdminRoute) return RouteConstants.login;
        }

        // Block admin routes for non-admin users
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

// AuthState wrapper - used by route guards
class AuthUserState {
  final String? uid;
  final String? role;
  final bool isEmailVerified;

  const AuthUserState({
    this.uid,
    this.role,
    this.isEmailVerified = false,
  });

  bool get isLoggedIn => uid != null;
  bool get isAdmin => role == 'admin';
  bool get isGuest => role == 'guest';
}

// Riverpod AsyncValue alias for use in guards
typedef AsyncValue<T> = _AsyncValue<T>;

abstract class _AsyncValue<T> {
  const _AsyncValue();

  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
  });
}
