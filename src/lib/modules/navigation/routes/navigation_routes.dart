import 'package:go_router/go_router.dart';
import 'package:src/modules/navigation/models/spot_model.dart';
import 'package:src/modules/navigation/screens/location_screen.dart';
import 'package:src/modules/navigation/screens/navigation_screen.dart';
import 'package:src/modules/navigation/screens/parking_map_screen.dart';
import 'package:src/modules/navigation/screens/parking_map_test_screen.dart';
import 'package:src/modules/navigation/screens/parking_results_screen.dart';
import 'package:src/modules/navigation/screens/parking_spot_detail_screen.dart';
import 'package:src/modules/navigation/screens/parking_lot_detail_screen.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';

class NavigationRoutes {
  static const String navigation = 'navigation';
  static const String location = 'location-test';
  static const String parkingMap = 'parking-map';
  static const String parkingMapTest = 'test-parking-map';
  static const String parkingResults = 'parking-results';
  static const String parkingSpotDetail = 'parking-spot-detail';
  static const String parkingLotDetail = 'parking-lot-detail';

  static const String navigationPath = '/navigation';
  static const String locationPath = '/location-test';
  static const String parkingMapPath = '/parking-map';
  static const String parkingMapTestPath = '/test-parking-map';
  static const String parkingResultsPath = '/parking-results';
  static const String parkingSpotDetailPath = '/parking-spot-detail/:id';
  static const String parkingLotDetailPath = '/parking-lot-detail/:id';
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
        if (state.extra is Map<String, dynamic>) {
          final extraMap = state.extra as Map<String, dynamic>;
          final spots = extraMap['spots'] as List<ParkingSpotModel>? ?? [];
          final selectedId = extraMap['initialSelectedSpotId'] as int?;
          return ParkingMapScreen(spots: spots, initialSelectedSpotId: selectedId);
        } else {
          final spots = state.extra as List<ParkingSpotModel>? ?? [];
          return ParkingMapScreen(spots: spots);
        }
      },
    ),
    GoRoute(
      path: NavigationRoutes.parkingMapTestPath,
      name: NavigationRoutes.parkingMapTest,
      builder: (context, state) {
        return ParkingMapTestScreen();
      },
    ),
    GoRoute(
      path: NavigationRoutes.parkingResultsPath,
      name: NavigationRoutes.parkingResults,
      builder: (context, state) {
        final cityQuery = state.extra as String;
        return ParkingResultsScreen(cityQuery: cityQuery);
      },
    ),
    GoRoute(
      path: NavigationRoutes.parkingSpotDetailPath,
      name: NavigationRoutes.parkingSpotDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ParkingSpotDetailScreen(spotId: id);
      },
    ),
    GoRoute(
      path: NavigationRoutes.parkingLotDetailPath,
      name: NavigationRoutes.parkingLotDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ParkingLotDetailScreen(lotId: id);
      },
    ),
  ];
}
