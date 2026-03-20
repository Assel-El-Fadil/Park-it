import 'package:go_router/go_router.dart';
import 'package:src/modules/navigation/models/spot_model.dart';
import 'package:src/modules/navigation/screens/location_screen.dart';
import 'package:src/modules/navigation/screens/navigation_screen.dart';
import 'package:src/modules/navigation/screens/parking_map_screen.dart';
import 'package:src/modules/navigation/screens/parking_map_test_screen.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';

class NavigationRoutes {
  static const String navigation = 'navigation';
  static const String location = 'location-test';
  static const String parkingMap = 'parking-map';
  static const String parkingMapTest = 'test-parking-map';

  static const String navigationPath = '/navigation';
  static const String locationPath = '/location-test';
  static const String parkingMapPath = '/parking-map';
  static const String parkingMapTestPath = '/test-parking-map';
}

List<GoRoute> getNavigationRoutes() {
  return [
    GoRoute(
      path: NavigationRoutes.locationPath,
      name: NavigationRoutes.location,
      builder: (context, state) {
        // Test Route
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
    GoRoute(
      path: NavigationRoutes.parkingMapPath,
      name: NavigationRoutes.parkingMap,
      builder: (context, state) {
        final spots = state.extra as List<ParkingSpotModel>;
        return ParkingMapScreen(spots: spots);
      },
    ),
    GoRoute(
      path: NavigationRoutes.parkingMapTestPath,
      name: NavigationRoutes.parkingMapTest,
      builder: (context, state) {
        return ParkingMapTestScreen();
      },
    ),
  ];
}
