import 'package:go_router/go_router.dart';

/// Navigation module route names
class NavigationRoutes {
  // Route names
  static const String mainNav = 'main-navigation';
  static const String bottomNav = 'bottom-nav';

  // Paths
  static const String mainNavPath = '/main';
  static const String bottomNavPath = '/bottom-nav';
}

/// Navigation module route configuration
List<GoRoute> getNavigationRoutes() {
  return [
    // GoRoute(
    //   path: NavigationRoutes.mainNavPath,
    //   name: NavigationRoutes.mainNav,
    //   builder: (context, state) => const MainNavigationScreen(),
    // ),
    // GoRoute(
    //   path: NavigationRoutes.bottomNavPath,
    //   name: NavigationRoutes.bottomNav,
    //   builder: (context, state) => const BottomNavBar(),
    // ),
  ];
}
