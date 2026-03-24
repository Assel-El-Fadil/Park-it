import 'package:src/core/enums/app_enums.dart';

class ReportModel {
  final int id;
  final String reporterId;
  final String targetId;
  final ReportTargetType targetType;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? resolvedBy;
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetId,
    required this.targetType,
    required this.reason,
    this.description,
    required this.status,
    this.resolvedBy,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int,
      reporterId: json['reporter_id'] as String,
      targetId: json['target_id']?.toString() ?? '',
      targetType: ReportTargetType.fromString(json['target_type'] as String),
      reason: ReportReason.fromString(json['reason'] as String),
      description: json['description'] as String?,
      status: ReportStatus.fromString(json['status'] as String),
      resolvedBy: json['resolved_by']?.toString(),
      resolution: json['resolution'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'target_id': targetId,
      'target_type': targetType.toJson(),
      'reason': reason.toJson(),
      'description': description,
      'status': status.toJson(),
      'resolved_by': resolvedBy,
      'resolution': resolution,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  bool get isResolved => status == ReportStatus.resolved;
  bool get isPending => status == ReportStatus.pending;
}
