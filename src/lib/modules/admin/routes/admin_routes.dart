import 'package:go_router/go_router.dart';
import 'package:src/modules/admin/screens/admin_dashboard_screen.dart';
import 'package:src/modules/admin/screens/admin_owner_verification_screen.dart';

class AdminRoutes {
  static const String dashboard = 'admin_dashboard';
  static const String dashboardPath = '/admin/dashboard';
  static const String ownerVerification = 'admin-owner-verification';
  static const String ownerVerificationPath = '/admin/owner-verification/:userId';
}

List<GoRoute> getAdminRoutes() {
  return [
    GoRoute(
      path: AdminRoutes.ownerVerificationPath,
      name: AdminRoutes.ownerVerification,
      builder: (context, state) {
        final id = state.pathParameters['userId'] ?? '';
        return AdminOwnerVerificationScreen(userId: id);
      },
    ),
    GoRoute(
      path: AdminRoutes.dashboardPath,
      name: AdminRoutes.dashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ];
}
