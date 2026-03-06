import 'package:go_router/go_router.dart';

/// Notification module route names
class NotificationRoutes {
  // Route names
  static const String notifications = 'notifications';
  static const String notificationDetail = 'notification-detail';
  static const String notificationSettings = 'notification-settings';

  // Paths
  static const String notificationsPath = '/notifications';
  static const String notificationDetailPath = '/notifications/:id';
  static const String notificationSettingsPath = '/notifications/settings';
}

/// Notification module route configuration
List<GoRoute> getNotificationRoutes() {
  return [
    // Notifications list
    // GoRoute(
    //   path: NotificationRoutes.notificationsPath,
    //   name: NotificationRoutes.notifications,
    //   builder: (context, state) {
    //     // Optional filter parameter
    //     final filter = state.uri.queryParameters['filter'];
    //     return NotificationsScreen(filter: filter);
    //   },
    // ),

    // // Notification detail
    // GoRoute(
    //   path: NotificationRoutes.notificationDetailPath,
    //   name: NotificationRoutes.notificationDetail,
    //   builder: (context, state) {
    //     final notificationId = state.pathParameters['id'] ?? '';
    //     return NotificationDetailScreen(notificationId: notificationId);
    //   },
    // ),

    // // Notification settings
    // GoRoute(
    //   path: NotificationRoutes.notificationSettingsPath,
    //   name: NotificationRoutes.notificationSettings,
    //   builder: (context, state) => const NotificationSettingsScreen(),
    // ),
  ];
}
