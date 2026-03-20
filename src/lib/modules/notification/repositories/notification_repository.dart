import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/notification/models/notification_model.dart';

class NotificationRepository extends SupabaseRepository<NotificationModel> {
  @override
  String get tableName => 'notifications';

  @override
  String getItemKey(NotificationModel item) => item.id.toString();

  @override
  Map<String, dynamic> toJson(NotificationModel item) => item.toJson();

  @override
  NotificationModel fromJson(Map<String, dynamic> json) =>
      NotificationModel.fromJson(json);

  Future<List<NotificationModel>> getByUserId(int userId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<List<NotificationModel>> getUnreadByUserId(int userId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: false);

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await client
        .from(tableName)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsReadForUser(int userId) async {
    await client
        .from(tableName)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<int> getUnreadCount(int userId) async {
    final response = await client
        .from(tableName)
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (response as List).length;
  }

  Future<List<NotificationModel>> getByType(
    int userId,
    NotificationType type,
  ) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('user_id', userId)
        .eq('type', type.toJson())
        .order('created_at', ascending: false);

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<List<NotificationModel>> getByReference(
    int userId,
    String referenceType,
    int referenceId,
  ) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('user_id', userId)
        .eq('reference_type', referenceType)
        .eq('reference_id', referenceId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<void> deleteOldNotifications({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    await client
        .from(tableName)
        .delete()
        .lt('created_at', cutoffDate.toIso8601String());
  }
}
