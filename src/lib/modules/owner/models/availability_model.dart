class AvailabilityModel {
  final int id;
  final int spotId;
  final int? dayOfWeek; // 0-6 (Sunday-Saturday)
  final DateTime? specificDate;
  final String openTime; // Format: HH:MM:SS
  final String closeTime; // Format: HH:MM:SS
  final bool isBlocked;

  AvailabilityModel({
    required this.id,
    required this.spotId,
    this.dayOfWeek,
    this.specificDate,
    required this.openTime,
    required this.closeTime,
    required this.isBlocked,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as int,
      spotId: json['spot_id'] as int,
      dayOfWeek: json['day_of_week'] as int?,
      specificDate: json['specific_date'] != null
          ? DateTime.parse(json['specific_date'] as String)
          : null,
      openTime: json['open_time'] as String,
      closeTime: json['close_time'] as String,
      isBlocked: json['is_blocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spot_id': spotId,
      'day_of_week': dayOfWeek,
      'specific_date': specificDate?.toIso8601String(),
      'open_time': openTime,
      'close_time': closeTime,
      'is_blocked': isBlocked,
    };
  }

  bool get isRecurring => dayOfWeek != null;
  bool get isOneTime => specificDate != null;
}
