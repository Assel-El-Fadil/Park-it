import 'package:go_router/go_router.dart';
import 'package:src/modules/auth/screens/forgot_password_screen.dart';
import 'package:src/modules/auth/screens/login_screen.dart';
import 'package:src/modules/auth/screens/register_screen.dart';
import 'package:src/modules/user/screens/profile_screen.dart';
import 'package:src/modules/user/screens/vehicle_screen.dart';

/// Auth module route names
class AuthRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String vehicles = '/vehicles';

  static const String forgotPassword = 'forgot-password';
  static const String forgotPasswordPath = '/forgot-password';
}

/// Auth module route configuration
List<GoRoute> getAuthRoutes() {
  return [
    GoRoute(
      path: AuthRoutes.login,
      name: AuthRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AuthRoutes.register,
      name: AuthRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AuthRoutes.profile,
      name: AuthRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AuthRoutes.vehicles,
      name: AuthRoutes.vehicles,
      builder: (context, state) => const VehicleScreen(),
    ),
    GoRoute(
      path: AuthRoutes.forgotPasswordPath,
      name: AuthRoutes.forgotPassword,
      builder: (context, state) => ForgotPasswordScreen(),
    ),
  ];
}
