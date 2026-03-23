import 'package:flutter/material.dart';

class AvailabilityModel {
  final int id;
  final int spotId;
  final int? dayOfWeek;
  final DateTime? specificDate;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
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
      openTime: _parseTime(json['open_time'] as String),
      closeTime: _parseTime(json['close_time'] as String),
      isBlocked: json['is_blocked'] as bool,
    );
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String get dayName {
    if (dayOfWeek == null) return '';
    return [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][dayOfWeek!];
  }

  String get timeRange => '${_formatTime(openTime)} - ${_formatTime(closeTime)}';

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
