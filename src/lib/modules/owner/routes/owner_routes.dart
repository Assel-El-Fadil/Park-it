import 'package:go_router/go_router.dart';
import 'package:src/modules/owner/screens/add_parking_space_screen.dart';
import 'package:src/modules/owner/screens/edit_parking_space_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_space_detail_screen.dart';
import 'package:src/modules/owner/screens/owner_shell_screen.dart';

/// Owner module route names
class OwnerRoutes {
  // Route names
  static const String ownerDashboard = 'owner-dashboard';
  static const String parkingSpaces = 'parking-spaces';
  static const String addParkingSpace = 'add-parking-space';
  static const String editParkingSpace = 'edit-parking-space';
  static const String parkingSpaceDetail = 'parking-space-detail';
  static const String ownerBookings = 'owner-bookings';
  static const String ownerEarnings = 'owner-earnings';
  static const String ownerProfile = 'owner-profile';
  static const String ownerSettings = 'owner-settings';

  // Paths
  static const String ownerDashboardPath = '/owner';
  static const String parkingSpacesPath = '/owner/spaces';
  static const String addParkingSpacePath = '/owner/spaces/add';
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

    // Spots CRUD
    GoRoute(
      path: OwnerRoutes.addParkingSpacePath,
      name: OwnerRoutes.addParkingSpace,
      builder: (context, state) => const AddParkingSpaceScreen(),
    ),
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
