import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/notification/routes/notification_routes.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/routes/reservation_routes.dart';
import 'package:src/modules/review/routes/review_routes.dart';
import 'package:src/modules/admin/routes/admin_routes.dart';
import 'package:src/modules/super_admin/routes/super_admin_routes.dart';
import 'package:src/modules/user/routes/user_routes.dart';
import 'package:src/modules/report/routes/report_routes.dart';
import 'package:src/shared/screens/landing_page.dart';
import 'package:src/shared/screens/privacy_policy_screen.dart';
import 'package:src/shared/screens/settings_screen.dart';
import 'package:src/shared/screens/splash_screen.dart';
import 'package:src/shared/screens/terms_of_service_screen.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/core/config/routes/router_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: AppNavigator.navigatorKey,
    initialLocation: AppRoutes.splashPath,
    refreshListenable: RouterNotifier(ref),
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider).value;
      if (authState == null) return null;

      final location = state.uri.toString();
      
      // 1. Auth-based redirection
      final bool isAuthenticated = authState.isAuthenticated;
      final bool isNewUser = authState.isNewUser;
      final bool justLoggedIn = authState.justLoggedIn;
      
      if (isAuthenticated) {
        // 2a. App Startup: Splash -> Profile (Existing) or Role Selection (New/Incomplete)
        if (state.matchedLocation == AppRoutes.splashPath) {
          if (isNewUser) {
            debugPrint('[GoRouter] New user authenticated without profile on startup, strictly forcing role selection');
            return AuthRoutes.roleSelectionPath;
          } else {
            debugPrint('[GoRouter] Valid profile found on startup, directing to Profile');
            return AppRoutes.profile;
          }
        }

        // 2b. Enforced role selection for NEW users (active session)
        if (isNewUser && state.matchedLocation != AuthRoutes.roleSelectionPath) {
          debugPrint('[GoRouter] New user authenticated without profile, strictly forcing role selection');
          return AuthRoutes.roleSelectionPath;
        }
        
        // 2c. Session handling: Prevent existing users from reaching Login/Register/Landing or Role Selection
        if (!isNewUser) {
           if (state.matchedLocation == '/' ||
               state.matchedLocation == AuthRoutes.login || 
               state.matchedLocation == AuthRoutes.register ||
               state.matchedLocation == AuthRoutes.roleSelectionPath) {
             debugPrint('[GoRouter] Already authenticated, directing to Profile');
             return AppRoutes.profile;
           }
        }
      } else {
        // 3. Unauthenticated Case: Ensure we are at Splash, Login or Register
        if (state.matchedLocation != AppRoutes.splashPath && 
            state.matchedLocation != AuthRoutes.login &&
            state.matchedLocation != AuthRoutes.register) {
          debugPrint('[GoRouter] Not authenticated, forcing redirect to Login');
          return AuthRoutes.login;
        }
      }

      return null;
    },
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
      if (getReportRoutes().isNotEmpty) ...getReportRoutes(),
      if (getAdminRoutes().isNotEmpty) ...getAdminRoutes(),
      if (getSuperAdminRoutes().isNotEmpty) ...getSuperAdminRoutes(),
    ],
  );
});
