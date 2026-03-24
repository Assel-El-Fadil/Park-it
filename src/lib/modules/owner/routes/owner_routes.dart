import 'package:go_router/go_router.dart';
import 'package:src/modules/owner/screens/add_parking_lot_screen.dart';
import 'package:src/modules/owner/screens/add_parking_space_screen.dart';
import 'package:src/modules/owner/screens/add_spot_to_lot_screen.dart';
import 'package:src/modules/owner/screens/edit_parking_space_screen.dart';
import 'package:src/modules/owner/screens/owner_bookings_screen.dart';
import 'package:src/modules/owner/screens/owner_earnings_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_space_detail_screen.dart';
import 'package:src/modules/owner/screens/owner_parkings_hub_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_lots_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_lot_detail_screen.dart';
import 'package:src/modules/owner/screens/owner_shell_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_spaces_screen.dart';
import 'package:src/modules/owner/screens/owner_standalone_spot_screen.dart';
import 'package:src/modules/owner/screens/owner_dynamic_pricing_screen.dart';
import 'package:src/modules/owner/screens/owner_availability_screen.dart';

/// Owner module route names
class OwnerRoutes {
  // Route names
  static const String ownerDashboard = 'owner-dashboard';
  static const String parkingSpaces = 'parking-spaces';
  static const String parkingLots = 'parking-lots';
  static const String addParkingSpace = 'add-parking-space';
  static const String editParkingSpace = 'edit-parking-space';
  static const String parkingSpaceDetail = 'parking-space-detail';
  static const String ownerParkingLotDetail = 'owner-parking-lot-detail';
  static const String ownerBookings = 'owner-bookings';
  static const String ownerEarnings = 'owner-earnings';
  static const String ownerAvailability = 'owner-availability';
  static const String ownerDynamicPricing = 'owner-dynamic-pricing';
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
  static const String parkingLotsPath = '/owner/lots';
  static const String addParkingSpacePath = '/owner/spaces/add';
  static const String editParkingSpacePath = '/owner/spaces/:id/edit';
  static const String parkingSpaceDetailPath = '/owner/spaces/:id';
  static const String parkingLotDetailPath = '/owner/lots/:id';
  static const String ownerBookingsPath = '/owner/bookings';
  static const String ownerEarningsPath = '/owner/earnings';
  static const String ownerAvailabilityPath = '/owner/spaces/:id/availability';
  static const String ownerDynamicPricingPath =
      '/owner/spaces/:id/dynamic-pricing';
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

    // Parking Lots
    GoRoute(
      path: OwnerRoutes.parkingLotsPath,
      name: OwnerRoutes.parkingLots,
      builder: (context, state) => const OwnerParkingLotsScreen(),
    ),
    GoRoute(
      path: OwnerRoutes.parkingLotDetailPath,
      name: OwnerRoutes.ownerParkingLotDetail,
      builder: (context, state) {
        final lotId = state.pathParameters['id'] ?? '';
        return OwnerParkingLotDetailScreen(parkingLotId: lotId);
      },
    ),

    // Spots CRUD
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

    // Add Parking Space
    GoRoute(
      path: OwnerRoutes.addParkingSpacePath,
      name: OwnerRoutes.addParkingSpace,
      builder: (context, state) => const AddParkingSpaceScreen(),
    ),

    // Parking Spaces List
    GoRoute(
      path: OwnerRoutes.parkingSpacesPath,
      name: OwnerRoutes.parkingSpaces,
      builder: (context, state) => const OwnerParkingSpacesScreen(),
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

    GoRoute(
      path: OwnerRoutes.ownerBookingsPath,
      name: OwnerRoutes.ownerBookings,
      builder: (context, state) => const OwnerBookingsScreen(),
    ),
    GoRoute(
      path: OwnerRoutes.ownerEarningsPath,
      name: OwnerRoutes.ownerEarnings,
      builder: (context, state) => const OwnerEarningsScreen(),
    ),

    GoRoute(
      path: OwnerRoutes.ownerAvailabilityPath,
      name: OwnerRoutes.ownerAvailability,
      builder: (context, state) {
        final spaceId = state.pathParameters['id'] ?? '';
        return OwnerAvailabilityScreen(spotId: spaceId);
      },
    ),
    GoRoute(
      path: OwnerRoutes.ownerDynamicPricingPath,
      name: OwnerRoutes.ownerDynamicPricing,
      builder: (context, state) {
        final spaceId = state.pathParameters['id'] ?? '';
        return OwnerDynamicPricingScreen(spotId: spaceId);
      },
    ),
  ];
}
