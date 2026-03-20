import 'package:go_router/go_router.dart';
import 'package:src/modules/notification/models/notification_model.dart';
import 'package:src/modules/notification/screens/notification_detail_screen.dart';
import 'package:src/modules/notification/screens/notification_screen.dart';
import 'package:src/modules/notification/screens/notification_settings_screen.dart';

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
    GoRoute(
      path: NotificationRoutes.notificationsPath,
      name: NotificationRoutes.notifications,
      builder: (context, state) {
        return NotificationScreen();
      },
    ),

    GoRoute(
      path: NotificationRoutes.notificationSettingsPath,
      name: NotificationRoutes.notificationSettings,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),

    // // Notification detail
    GoRoute(
      path: NotificationRoutes.notificationDetailPath,
      name: NotificationRoutes.notificationDetail,
      builder: (context, state) {
        final notificationId = int.parse(state.pathParameters['id'] ?? '0');
        final notification = state.extra as NotificationModel?;

        return NotificationDetailScreen(
          notificationId: notificationId,
          notification: notification,
        );
      },
    ),

    // Notification settings
  ];
}

class NotificationsScreen {}
