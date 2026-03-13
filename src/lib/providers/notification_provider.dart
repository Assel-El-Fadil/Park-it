import 'package:flutter_riverpod/legacy.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/notification/models/notification_model.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
      return NotificationNotifier();
    });

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]) {
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    state = [
      NotificationModel(
        id: 1,
        userId: 123,
        type: NotificationType.bookingConfirmed,
        title: 'Downtown Parking',
        content:
            'Your parking booking has been confirmed for tomorrow at 2:00 PM',
        referenceId: 456,
        referenceType: 'booking',
        isRead: false,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: 2,
        userId: 123,
        type: NotificationType.paymentReceived,
        title: 'Payment Successful',
        content:
            'Your payment of \$15.50 for Downtown Parking has been processed',
        referenceId: 789,
        referenceType: 'payment',
        isRead: false,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 3,
        userId: 123,
        type: NotificationType.reviewReceived,
        title: 'New Review',
        content:
            'Sarah left you a 5-star review! "Great host, very responsive"',
        referenceId: 101,
        referenceType: 'review',
        isRead: true,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 4,
        userId: 123,
        type: NotificationType.promotion,
        title: 'Weekend Special',
        content: 'Get 20% off on all downtown parking this weekend',
        referenceId: null,
        referenceType: 'promo',
        isRead: false,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 5,
        userId: 123,
        type: NotificationType.bookingReminder,
        title: 'Upcoming Booking',
        content: 'Your parking starts in 2 hours at Airport Parking',
        referenceId: 457,
        referenceType: 'booking',
        isRead: true,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: 6,
        userId: 123,
        type: NotificationType.paymentFailed,
        title: 'Payment Failed',
        content:
            'Unable to process payment for your booking. Please update payment method',
        referenceId: 790,
        referenceType: 'payment',
        isRead: false,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: 7,
        userId: 123,
        type: NotificationType.messageReceived,
        title: 'Message from Host',
        content: 'John: "I left the gate code in your messages"',
        referenceId: 102,
        referenceType: 'message',
        isRead: false,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: 8,
        userId: 123,
        type: NotificationType.specialOffer,
        title: 'Refer a Friend',
        content: 'Refer a friend and both get \$10 off your next booking!',
        referenceId: null,
        referenceType: 'referral',
        isRead: true,
        channel: NotificationChannel.inApp,
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  void markAsRead(int id) {
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
  }

  void markAllAsRead() {
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
  }

  void deleteNotification(int id) {
    state = state.where((notification) => notification.id != id).toList();
  }

  void clearAll() {
    state = [];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

// Filter provider
final notificationFilterProvider = StateProvider<NotificationType?>(
  (ref) => null,
);
