import 'package:src/core/enums/app_enums.dart';

class ReservationModel {
  final int id;
  final String driverId;
  final int spotId;
  final int vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final double totalPrice;
  final double platformFee;
  final DateTime? lockExpiresAt;
  final String? cancellationReason;
  final String? accessCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReservationModel({
    required this.id,
    required this.driverId,
    required this.spotId,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    required this.platformFee,
    this.lockExpiresAt,
    this.cancellationReason,
    this.accessCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String dateStr) {
      return DateTime.parse(dateStr.endsWith('Z') ? dateStr : '${dateStr}Z').toLocal();
    }

    return ReservationModel(
      id: json['id'] as int,
      driverId: json['driver_id'] as String,
      spotId: json['spot_id'] as int,
      vehicleId: json['vehicle_id'] as int,
      startTime: parseDate(json['start_time'] as String),
      endTime: parseDate(json['end_time'] as String),
      status: ReservationStatus.fromString(json['status'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      lockExpiresAt: json['lock_expires_at'] != null
          ? parseDate(json['lock_expires_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      accessCode: json['access_code'] as String?,
      createdAt: parseDate(json['created_at'] as String),
      updatedAt: parseDate(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'spot_id': spotId,
      'vehicle_id': vehicleId,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'status': status.toJson(),
      'total_price': totalPrice,
      'platform_fee': platformFee,
      'lock_expires_at': lockExpiresAt?.toUtc().toIso8601String(),
      'cancellation_reason': cancellationReason,
      'access_code': accessCode,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  Duration get duration => endTime.difference(startTime);
  double get ownerPayout => totalPrice - platformFee;
  bool get isActive => status == ReservationStatus.active;
  bool get isCancellable =>
      status == ReservationStatus.pending ||
      status == ReservationStatus.confirmed;
}
