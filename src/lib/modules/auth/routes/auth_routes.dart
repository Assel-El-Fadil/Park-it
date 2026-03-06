import 'package:go_router/go_router.dart';
import 'package:src/modules/auth/screens/forgot_password_screen.dart';
import 'package:src/modules/auth/screens/login_screen.dart';
import 'package:src/modules/auth/screens/register_screen.dart';

/// Auth module route names
class AuthRoutes {
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';

  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
}

/// Auth module route configuration
List<GoRoute> getAuthRoutes() {
  return [
    GoRoute(
      path: AuthRoutes.loginPath,
      name: AuthRoutes.login,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: AuthRoutes.registerPath,
      name: AuthRoutes.register,
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: AuthRoutes.forgotPasswordPath,
      name: AuthRoutes.forgotPassword,
      builder: (context, state) => ForgotPasswordScreen(),
    ),
  ];
}
