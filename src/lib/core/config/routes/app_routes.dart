import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/notification/routes/notification_routes.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/routes/reservation_routes.dart';
import 'package:src/modules/review/routes/review_routes.dart';
import 'package:src/modules/user/routes/user_routes.dart';
import 'package:src/shared/screens/splash_screen.dart';

class AppRoutes {
  // Auth routes
  static const String splash = 'splash';

  // Auth
  static const String login = AuthRoutes.login;
  static const String register = AuthRoutes.register;

  // Paths
  static const String splashPath = '/splash';
}

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Helper Methods
  static void goToLogin(BuildContext context) =>
      context.goNamed(AppRoutes.login);

  static void goToRegister(BuildContext context) =>
      context.goNamed(AppRoutes.register);

  // Push named routes
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? extra,
  }) {
    return GoRouter.of(context).pushNamed(routeName, extra: extra);
  }

  // Go to named routes
  static void goNamed(BuildContext context, String routeName, {Object? extra}) {
    GoRouter.of(context).goNamed(routeName, extra: extra);
  }

  // Push replacement
  static Future<T?> pushReplacementNamed<T>(
    BuildContext context,
    String routeName, {
    Object? extra,
  }) {
    return GoRouter.of(context).pushReplacementNamed(routeName, extra: extra);
  }

  // Pop
  static void pop(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    }
  }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: AppNavigator.navigatorKey,
  initialLocation: AppRoutes.splashPath,
  debugLogDiagnostics: true,
  routes: [
    // Splash
    GoRoute(
      path: AppRoutes.splashPath,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Module Routes
    ...getAuthRoutes(),
    ...getAuthRoutes(),
    ...getNavigationRoutes(),
    ...getReviewRoutes(),
    ...getOwnerRoutes(),
    ...getPaymentRoutes(),
    ...getUserRoutes(),
    ...getReservationRoutes(),
    ...getNotificationRoutes(),
  ],
);
