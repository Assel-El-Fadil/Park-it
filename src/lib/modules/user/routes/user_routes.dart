import 'package:go_router/go_router.dart';
import 'package:src/modules/user/screens/edit_profile_screen.dart';

/// User module route names
class UserRoutes {
  // Route names
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String userSettings = 'user-settings';
  static const String favoriteSpaces = 'favorite-spaces';
  static const String userVehicles = 'user-vehicles';
  static const String addVehicle = 'add-vehicle';
  static const String editVehicle = 'edit-vehicle';
  static const String notificationSettings = 'notification-settings';
  static const String privacySettings = 'privacy-settings';

  // Paths
  static const String profilePath = '/profile';
  static const String editProfilePath = '/profile/edit';
  static const String userSettingsPath = '/profile/settings';
  static const String favoriteSpacesPath = '/profile/favorites';
  static const String userVehiclesPath = '/profile/vehicles';
  static const String addVehiclePath = '/profile/vehicles/add';
  static const String editVehiclePath = '/profile/vehicles/:id/edit';
  static const String notificationSettingsPath =
      '/profile/settings/notifications';
  static const String privacySettingsPath = '/profile/settings/privacy';
}

/// User module route configuration
List<GoRoute> getUserRoutes() {
  return [
    // Profile and Vehicles moved to auth_routes
    GoRoute(
      path: UserRoutes.editProfilePath,
      name: UserRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),

    // // Settings
    // GoRoute(
    //   path: UserRoutes.userSettingsPath,
    //   name: UserRoutes.userSettings,
    //   builder: (context, state) => const UserSettingsScreen(),
    // ),
    // GoRoute(
    //   path: UserRoutes.notificationSettingsPath,
    //   name: UserRoutes.notificationSettings,
    //   builder: (context, state) => const NotificationSettingsScreen(),
    // ),
    // GoRoute(
    //   path: UserRoutes.privacySettingsPath,
    //   name: UserRoutes.privacySettings,
    //   builder: (context, state) => const PrivacySettingsScreen(),
    // ),

    // // Favorites
    // GoRoute(
    //   path: UserRoutes.favoriteSpacesPath,
    //   name: UserRoutes.favoriteSpaces,
    //   builder: (context, state) => const FavoriteSpacesScreen(),
    // ),

    // Vehicles - defined in auth_routes
    // GoRoute(
    //   path: UserRoutes.addVehiclePath,
    //   name: UserRoutes.addVehicle,
    //   builder: (context, state) => const AddVehicleScreen(),
    // ),
    // GoRoute(
    //   path: UserRoutes.editVehiclePath,
    //   name: UserRoutes.editVehicle,
    //   builder: (context, state) {
    //     final vehicleId = state.pathParameters['id'] ?? '';
    //     return EditVehicleScreen(vehicleId: vehicleId);
    //   },
    // ),
  ];
}
