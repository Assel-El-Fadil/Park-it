import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/enums/app_enums.dart';
import '../modules/notification/models/notification_model.dart';
import '../modules/notification/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notification provider
final notificationProvider =
    NotifierProvider<NotificationNotifier, List<NotificationModel>>(() {
      return NotificationNotifier();
    });

class NotificationNotifier extends Notifier<List<NotificationModel>> {
  late final NotificationService _service;
  String _userId = ''; // This should come from your auth provider

  @override
  List<NotificationModel> build() {
    _service = ref.watch(notificationServiceProvider);
    // Listen for changes in the user ID if it comes from another provider
    // For now, we'll assume setCurrentUserId is called externally.
    _loadNotifications();
    return [];
  }

  Future<void> _loadNotifications() async {
    if (_userId.isEmpty) return;
    try {
      final notifications = await _service.getUserNotifications(_userId);
      state = notifications;
    } catch (e) {
      print('Error loading notifications: $e');
      state = [];
    }
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _service.markNotificationAsRead(notificationId);

      // Update local state
      state = [
        for (final n in state)
          if (n.id == notificationId) n.copyWith(isRead: true) else n
      ];
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId.isEmpty) return;
    try {
      await _service.markAllUserNotificationsAsRead(_userId);

      state = [for (final n in state) n.copyWith(isRead: true)];
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _service.deleteNotification(id);
      state = state.where((notification) => notification.id != id).toList();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _service.clearAllNotifications();
      state = [];
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _service.addNotification(notification);
      await _loadNotifications(); // Reload to get the latest
    } catch (e) {
      throw Exception('Error adding notification: $e');
    }
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  void setCurrentUserId(String userId) {
    _userId = userId;
    _loadNotifications();
  }
}

// Filter notifier
class NotificationFilterNotifier extends Notifier<NotificationType?> {
  @override
  NotificationType? build() => null;

  void setFilter(NotificationType? filter) {
    state = filter;
  }
}

final notificationFilterProvider =
    NotifierProvider<NotificationFilterNotifier, NotificationType?>(() {
  return NotificationFilterNotifier();
});

// Filtered notifications provider
final filteredNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationProvider);
  final filter = ref.watch(notificationFilterProvider);

  if (filter == null) return notifications;

  return notifications.where((n) => n.type == filter).toList();
});
