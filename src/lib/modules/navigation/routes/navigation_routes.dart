import 'package:go_router/go_router.dart';
import 'package:src/modules/navigation/screens/parking_navigation_screen.dart';

/// Navigation module route names
class NavigationRoutes {
  static const String navigation = 'navigation';

  static const String navigationPath = '/navigation';
}

/// Navigation module route configuration
List<GoRoute> getNavigationRoutes() {
  return [
    // GoRoute(
    //   path: NavigationRoutes.navigationPath,
    //   name: NavigationRoutes.navigation,
    //   builder: (context, state) {
    //     final extra = state.extra as Map<String, dynamic>;
    //     return ParkingNavigationScreen(
    //       booking: extra['booking'],
    //       parkingLocation: extra['coordinates'],
    //     );
    //   },
    // ),
  ];
}
