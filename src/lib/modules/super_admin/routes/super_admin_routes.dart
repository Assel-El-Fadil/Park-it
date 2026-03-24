import 'package:go_router/go_router.dart';
import 'package:src/modules/super_admin/screens/super_admin_dashboard_screen.dart';
import 'package:src/modules/super_admin/screens/super_admin_admins_screen_fixed.dart';
import 'package:src/modules/super_admin/screens/super_admin_add_admin_screen_simple.dart';

/// Super Admin module route names
class SuperAdminRoutes {
  // Route names
  static const String dashboard = 'super-admin-dashboard';
  static const String admins = 'super-admin-admins';
  static const String addAdmin = 'super-admin-add-admin';

  // Paths
  static const String dashboardPath = '/super-admin';
  static const String adminsPath = '/super-admin/admins';
  static const String addAdminPath = '/super-admin/admins/add';
}

/// Super Admin module route configuration
List<GoRoute> getSuperAdminRoutes() {
  return [
    // Super Admin Dashboard
    GoRoute(
      path: SuperAdminRoutes.dashboardPath,
      name: SuperAdminRoutes.dashboard,
      builder: (context, state) => const SuperAdminDashboardScreen(),
    ),
    
    // Admins Management
    GoRoute(
      path: SuperAdminRoutes.adminsPath,
      name: SuperAdminRoutes.admins,
      builder: (context, state) => const SuperAdminAdminsScreenFixed(),
    ),
    
    // Add Admin
    GoRoute(
      path: SuperAdminRoutes.addAdminPath,
      name: SuperAdminRoutes.addAdmin,
      builder: (context, state) => const SuperAdminAddAdminScreenSimple(),
    ),
  ];
}
