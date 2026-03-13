import 'package:src/core/enums/app_enums.dart';

class ReservationModel {
  final int id;
  final int driverId;
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
    return ReservationModel(
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      spotId: json['spot_id'] as int,
      vehicleId: json['vehicle_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: ReservationStatus.fromString(json['status'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      lockExpiresAt: json['lock_expires_at'] != null
          ? DateTime.parse(json['lock_expires_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      accessCode: json['access_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'spot_id': spotId,
      'vehicle_id': vehicleId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.toJson(),
      'total_price': totalPrice,
      'platform_fee': platformFee,
      'lock_expires_at': lockExpiresAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'access_code': accessCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Duration get duration => endTime.difference(startTime);
  double get ownerPayout => totalPrice - platformFee;
  bool get isActive => status == ReservationStatus.active;
  bool get isCancellable =>
      status == ReservationStatus.pending ||
      status == ReservationStatus.confirmed;
}
