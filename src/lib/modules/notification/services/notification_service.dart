import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/notification/repositories/notification_repository.dart';

import '../models/notification_model.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository();

  Future<void> addNotification(NotificationModel notification) async {
    await _repository.add(notification);
  }

  Future<void> addNotifications(List<NotificationModel> notifications) async {
    await _repository.addAll(notifications);
  }

  Future<NotificationModel?> getNotificationById(int id) async {
    return await _repository.getById(id.toString());
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    return await _repository.getAll();
  }

  Future<void> updateNotification(
    int id,
    NotificationModel notification,
  ) async {
    await _repository.update(id.toString(), notification);
  }

  Future<void> deleteNotification(int id) async {
    await _repository.delete(id.toString());
  }

  Future<void> clearAllNotifications() async {
    await _repository.clear();
  }

  // User-specific methods
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    return await _repository.getByUserId(userId);
  }

  Future<List<NotificationModel>> getUserUnreadNotifications(
    String userId,
  ) async {
    return await _repository.getUnreadByUserId(userId);
  }

  Future<int> getUserUnreadCount(String userId) async {
    return await _repository.getUnreadCount(userId);
  }

  // Mark as read methods
  Future<void> markNotificationAsRead(int notificationId) async {
    await _repository.markAsRead(notificationId);
  }

  Future<void> markAllUserNotificationsAsRead(String userId) async {
    await _repository.markAllAsReadForUser(userId);
  }

  // Filter methods
  Future<List<NotificationModel>> getUserNotificationsByType(
    String userId,
    NotificationType type,
  ) async {
    return await _repository.getByType(userId, type);
  }

  Future<List<NotificationModel>> getUserNotificationsByReference(
    String userId,
    String referenceType,
    int referenceId,
  ) async {
    return await _repository.getByReference(userId, referenceType, referenceId);
  }

  // Batch operations
  Future<void> deleteOldNotifications({int daysOld = 30}) async {
    await _repository.deleteOldNotifications(daysOld: daysOld);
  }
}
