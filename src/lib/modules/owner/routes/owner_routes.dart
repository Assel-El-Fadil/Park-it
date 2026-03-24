import 'package:go_router/go_router.dart';
import 'package:src/modules/owner/screens/add_parking_lot_screen.dart';
import 'package:src/modules/owner/screens/add_spot_to_lot_screen.dart';
import 'package:src/modules/owner/screens/edit_parking_space_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_space_detail_screen.dart';
import 'package:src/modules/owner/screens/owner_parkings_hub_screen.dart';
import 'package:src/modules/owner/screens/owner_shell_screen.dart';
import 'package:src/modules/owner/screens/owner_standalone_spot_screen.dart';

/// Owner module route names
class OwnerRoutes {
  // Route names
  static const String ownerDashboard = 'owner-dashboard';
  static const String parkingSpaces = 'parking-spaces';
  static const String editParkingSpace = 'edit-parking-space';
  static const String parkingSpaceDetail = 'parking-space-detail';
  static const String ownerBookings = 'owner-bookings';
  static const String ownerEarnings = 'owner-earnings';
  static const String ownerProfile = 'owner-profile';
  static const String ownerSettings = 'owner-settings';
  static const String ownerMesParkings = 'owner-mes-parkings';
  static const String ownerAddLot = 'owner-add-lot';
  static const String ownerAddSpotToLot = 'owner-add-spot-to-lot';
  static const String ownerStandaloneSpot = 'owner-standalone-spot';

  // Paths
  static const String ownerDashboardPath = '/owner';
  static const String ownerMesParkingsPath = '/owner/parkings';
  static const String addParkingLotPath = '/owner/parkings/lot/add';
  static const String addSpotToLotPath = '/owner/parkings/lot/:lotId/spot/add';
  static const String ownerStandaloneSpotPath = '/owner/parkings/spot/standalone';
  static const String parkingSpacesPath = '/owner/spaces';
  static const String editParkingSpacePath = '/owner/spaces/:id/edit';
  static const String parkingSpaceDetailPath = '/owner/spaces/:id';
  static const String ownerBookingsPath = '/owner/bookings';
  static const String ownerEarningsPath = '/owner/earnings';
  static const String ownerProfilePath = '/owner/profile';
  static const String ownerSettingsPath = '/owner/settings';
}

/// Owner module route configuration
List<GoRoute> getOwnerRoutes() {
  return [
    // Owner shell (dashboard / spots / reviews / reports)
    GoRoute(
      path: OwnerRoutes.ownerDashboardPath,
      name: OwnerRoutes.ownerDashboard,
      builder: (context, state) => const OwnerShellScreen(),
    ),

    GoRoute(
      path: OwnerRoutes.ownerMesParkingsPath,
      name: OwnerRoutes.ownerMesParkings,
      builder: (context, state) => const OwnerParkingsHubScreen(),
    ),
    GoRoute(
      path: OwnerRoutes.addParkingLotPath,
      name: OwnerRoutes.ownerAddLot,
      builder: (context, state) => const AddParkingLotScreen(),
    ),
    GoRoute(
      path: OwnerRoutes.addSpotToLotPath,
      name: OwnerRoutes.ownerAddSpotToLot,
      builder: (context, state) {
        final lotId = int.tryParse(state.pathParameters['lotId'] ?? '') ?? 0;
        return AddSpotToLotScreen(lotId: lotId);
      },
    ),
    GoRoute(
      path: OwnerRoutes.ownerStandaloneSpotPath,
      name: OwnerRoutes.ownerStandaloneSpot,
      builder: (context, state) => const OwnerStandaloneSpotScreen(),
    ),
    // Spots CRUD
    GoRoute(
      path: OwnerRoutes.editParkingSpacePath,
      name: OwnerRoutes.editParkingSpace,
      builder: (context, state) {
        final spaceId = state.pathParameters['id'] ?? '';
        return EditParkingSpaceScreen(parkingSpaceId: spaceId);
      },
    ),
    GoRoute(
      path: OwnerRoutes.parkingSpaceDetailPath,
      name: OwnerRoutes.parkingSpaceDetail,
      builder: (context, state) {
        final spaceId = state.pathParameters['id'] ?? '';
        return OwnerParkingSpaceDetailScreen(parkingSpaceId: spaceId);
      },
    ),
  ];
}
