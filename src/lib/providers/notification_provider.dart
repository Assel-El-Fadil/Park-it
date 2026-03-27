import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/notification/models/notification_model.dart';
import 'package:src/modules/notification/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
      final service = ref.watch(notificationServiceProvider);
      final userId = ref.watch(currentUserProvider)?.id;
      return NotificationNotifier(service, userId);
    });

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  final NotificationService _service;
  String? _currentUserId;

  NotificationNotifier(this._service, this._currentUserId) : super([]) {
    if (_currentUserId != null) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    if (_currentUserId == null) {
      state = [];
      return;
    }
    try {
      final notifications = await _service.getUserNotifications(
        _currentUserId!,
      );
      state = notifications;
    } catch (e) {
      state = [];
      throw Exception('Error loading notifications: $e');
    }
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markNotificationAsRead(id);

      state = state.map((notification) {
        if (notification.id == id) {
          return NotificationModel(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            title: notification.title,
            content: notification.content,
            referenceId: notification.referenceId,
            referenceType: notification.referenceType,
            isRead: true,
            channel: notification.channel,
            sentAt: notification.sentAt,
            createdAt: notification.createdAt,
          );
        }
        return notification;
      }).toList();
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllUserNotificationsAsRead(_currentUserId!);

      state = state.map((notification) {
        return NotificationModel(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          content: notification.content,
          referenceId: notification.referenceId,
          referenceType: notification.referenceType,
          isRead: true,
          channel: notification.channel,
          sentAt: notification.sentAt,
          createdAt: notification.createdAt,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _service.deleteNotification(id);
      state = state.where((notification) => notification.id != id).toList();
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _service.clearAllNotifications();
      state = [];
    } catch (e) {
      throw Exception('Error clearing notifications: $e');
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
    _currentUserId = userId;
    _loadNotifications();
  }
}

// Filter provider
final notificationFilterProvider = StateProvider<NotificationType?>(
  (ref) => null,
);

// Filtered notifications provider
final filteredNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationProvider);
  final filter = ref.watch(notificationFilterProvider);

  if (filter == null) return notifications;

  return notifications.where((n) => n.type == filter).toList();
});
