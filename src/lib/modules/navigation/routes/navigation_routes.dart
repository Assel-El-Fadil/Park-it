import 'package:go_router/go_router.dart';
import 'package:src/modules/navigation/models/spot_model.dart';
import 'package:src/modules/navigation/screens/location_screen.dart';
import 'package:src/modules/navigation/screens/navigation_screen.dart';

/// Navigation module route names
class NavigationRoutes {
  static const String navigation = 'navigation';
  static const String location = 'location-test';

  static const String navigationPath = '/navigation';
  static const String locationPath = '/location-test';
}

/// Navigation module route configuration
List<GoRoute> getNavigationRoutes() {
  return [
    GoRoute(
      path: NavigationRoutes.locationPath,
      name: NavigationRoutes.location,
      builder: (context, state) {
        return LocationScreen();
      },
    ),

    GoRoute(
      path: NavigationRoutes.navigationPath,
      name: NavigationRoutes.navigation,
      builder: (context, state) {
        final extra = state.extra as SpotModel;
        return NavigationScreen(
          destLat: extra.latitude,
          destLng: extra.longitude,
          placeName: extra.name,
        );
      },
    ),
  ];
}
