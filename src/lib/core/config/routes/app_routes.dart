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
import 'package:src/shared/screens/landing_page.dart';
import 'package:src/shared/screens/privacy_policy_screen.dart';
import 'package:src/shared/screens/settings_screen.dart';
import 'package:src/shared/screens/splash_screen.dart';
import 'package:src/shared/screens/terms_of_service_screen.dart';

class AppRoutes {
  // App routes
  static const String splash = 'splash';
  static const String termsOfService = 'terms';
  static const String privacyPolicy = 'policy';
  static const String settings = 'settings';

  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String vehicles = '/vehicles';

  // Paths
  static const String splashPath = '/splash';
  static const String privacyPolicyPath = '/policy';
  static const String termsOfServicePath = '/terms';
  static const String settingsPath = '/settings';
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
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  }) {
    return GoRouter.of(context).pushNamed(
      routeName,
      extra: extra,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
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
  initialLocation: NotificationRoutes.notificationsPath,
  debugLogDiagnostics: true,
  routes: [
    // Landing Page
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),
    // Splash
    GoRoute(
      path: AppRoutes.splashPath,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    //Privacy Policy
    GoRoute(
      path: AppRoutes.privacyPolicyPath,
      name: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),

    //Terms of Service
    GoRoute(
      path: AppRoutes.termsOfServicePath,
      name: AppRoutes.termsOfService,
      builder: (context, state) => const TermsOfServiceScreen(),
    ),

    //Settings
    GoRoute(
      path: AppRoutes.settingsPath,
      name: AppRoutes.settings,
      builder: (context, state) => SettingsScreen(),
    ),

    // Module Routes
    if (getAuthRoutes().isNotEmpty) ...getAuthRoutes(),
    if (getNavigationRoutes().isNotEmpty) ...getNavigationRoutes(),
    if (getReviewRoutes().isNotEmpty) ...getReviewRoutes(),
    if (getOwnerRoutes().isNotEmpty) ...getOwnerRoutes(),
    if (getPaymentRoutes().isNotEmpty) ...getPaymentRoutes(),
    if (getUserRoutes().isNotEmpty) ...getUserRoutes(),
    if (getReservationRoutes().isNotEmpty) ...getReservationRoutes(),
    if (getNotificationRoutes().isNotEmpty) ...getNotificationRoutes(),
  ],
);
