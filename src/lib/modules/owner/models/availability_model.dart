import 'package:flutter/material.dart';

/// Represents a recurring weekly availability rule for a parking spot.
///
/// [dayOfWeek] follows the same convention as Dart's [DateTime.weekday]:
///   1 = Monday … 7 = Sunday   (ISO 8601)
///
/// Rows in the `availabilities` table use the same 1–7 encoding
/// in the `day_of_week` column.  The old `specific_date` column is
/// no longer used by this model.
class AvailabilityModel {
  final int id;
  final int spotId;

  /// Day of week matching the DB CHECK constraint:
  /// 0 = Sunday, 1 = Monday … 6 = Saturday.
  final int dayOfWeek;

  /// Whether the spot is closed on this day.
  final bool isBlocked;

  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const AvailabilityModel({
    required this.id,
    required this.spotId,
    required this.dayOfWeek,
    required this.isBlocked,
    required this.openTime,
    required this.closeTime,
  });

  /// Default open rule for [dayOfWeek] – used when no DB record exists yet.
  factory AvailabilityModel.defaultOpen(int spotId, int dayOfWeek) {
    return AvailabilityModel(
      id: -1,
      spotId: spotId,
      dayOfWeek: dayOfWeek,
      isBlocked: false,
      openTime: const TimeOfDay(hour: 8, minute: 0),
      closeTime: const TimeOfDay(hour: 22, minute: 0),
    );
  }

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as int,
      spotId: json['spot_id'] as int,
      dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? -1,
      isBlocked: json['is_blocked'] as bool,
      openTime: _parseTime(json['open_time'] as String),
      closeTime: _parseTime(json['close_time'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'spot_id': spotId,
    'day_of_week': dayOfWeek,
    'specific_date': null,
    'open_time': _formatForDb(openTime),
    'close_time': _formatForDb(closeTime),
    'is_blocked': isBlocked,
  };

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _formatForDb(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  /// Display name for this day.
  String get dayName => _dayNames[dayOfWeek] ?? '';

  /// DB convention: 0=Sunday, 1=Monday … 6=Saturday.
  static const _dayNames = {
    0: 'Sunday',
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
  };

  /// E.g. "8:00 AM – 10:00 PM"
  String get timeRange => '${_fmt(openTime)} – ${_fmt(closeTime)}';

  String _fmt(TimeOfDay t) {
    final hour = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final period = t.hour >= 12 ? 'PM' : 'AM';
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  AvailabilityModel copyWith({
    bool? isBlocked,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) {
    return AvailabilityModel(
      id: id,
      spotId: spotId,
      dayOfWeek: dayOfWeek,
      isBlocked: isBlocked ?? this.isBlocked,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }
}
