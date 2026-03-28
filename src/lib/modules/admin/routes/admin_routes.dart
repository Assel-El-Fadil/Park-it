import 'package:go_router/go_router.dart';
import 'package:src/modules/admin/screens/admin_dashboard_screen.dart';

class AdminRoutes {
  static const String dashboard = 'admin_dashboard';
  static const String dashboardPath = '/admin/dashboard';
}

List<GoRoute> getAdminRoutes() {
  return [
    GoRoute(
      path: AdminRoutes.dashboardPath,
      name: AdminRoutes.dashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ];
}
