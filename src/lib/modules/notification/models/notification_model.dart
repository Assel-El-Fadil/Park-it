import 'package:src/core/enums/app_enums.dart';

class NotificationModel {
  final int id; //notification id
  final String userId; // target user
  final NotificationType type; //paymentFailed, paymentReceived e.t.c
  final String title;
  final String content;
  final int? referenceId; // issue: booking, payment
  final String? referenceType;
  final bool isRead;
  final NotificationChannel channel; //inApp, push or email notification
  final DateTime? sentAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    required this.channel,
    this.sentAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'].toString(),
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      referenceId: json['reference_id'] as int?,
      referenceType: json['reference_type'] as String?,
      isRead: json['is_read'] as bool,
      channel: NotificationChannel.fromString(json['channel'] as String),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toJson(),
      'title': title,
      'content': content,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'is_read': isRead,
      'channel': channel.toJson(),
      'sent_at': sentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  NotificationModel copyWith({
    int? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? content,
    int? referenceId,
    String? referenceType,
    bool? isRead,
    NotificationChannel? channel,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      isRead: isRead ?? this.isRead,
      channel: channel ?? this.channel,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
