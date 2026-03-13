// lib/core/enums/user_enums.dart

import 'package:flutter/material.dart';

enum UserRole {
  driver,
  owner,
  admin,
  superAdmin;

  static UserRole fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => UserRole.driver,
    );
  }

  String toJson() => name.toUpperCase();
}

enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  static VerificationStatus fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => VerificationStatus.unverified,
    );
  }

  String toJson() => name.toUpperCase();
}

enum VehicleType {
  car,
  motorcycle,
  van,
  truck,
  electric;

  static VehicleType fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => VehicleType.car,
    );
  }

  String toJson() => name.toUpperCase();
}

enum SpotType {
  outdoor,
  indoor,
  covered,
  valet,
  garage,
  street;

  static SpotType fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SpotType.outdoor,
    );
  }

  String toJson() => name.toUpperCase();
}

enum SpotStatus {
  available,
  archived,
  suspended;

  static SpotStatus fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SpotStatus.available,
    );
  }

  String toJson() => name.toUpperCase();
}

enum Amenity {
  cctv,
  lighting,
  evCharger,
  wheelchair,
  guard,
  carWash;

  static Amenity fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Amenity.cctv,
    );
  }

  String toJson() => name.toUpperCase();
}

enum ReservationStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  expired,
  refunded;

  static ReservationStatus fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ReservationStatus.pending,
    );
  }

  String toJson() => name.toUpperCase();
}

enum PaymentStatus {
  pending,
  succeeded,
  failed,
  refunded;

  static PaymentStatus fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentStatus.pending,
    );
  }

  String toJson() => name.toUpperCase();
}

enum PaymentMethod {
  card,
  applePay,
  googlePay;

  static PaymentMethod fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentMethod.card,
    );
  }

  String toJson() => name.toUpperCase();

  IconData get icon {
    switch (this) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.account_balance_wallet;
    }
  }

  String get type {
    switch (this) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.applePay:
        return 'Digital Wallet';
      case PaymentMethod.googlePay:
        return 'Digital Wallet';
    }
  }

  bool get isDefault => this == PaymentMethod.card;
}

enum NotificationType {
  paymentFailed,
  reviewReceived,
  bookingConfirmed,
  bookingReminder,
  bookingCancelled,
  paymentReceived,
  refundProcessed,
  messageReceived,
  promotion,
  system,
  parkingUnavailable,
  hostResponse,
  specialOffer;

  static NotificationType fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationType.bookingCancelled,
    );
  }

  IconData get icon {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_rounded;
      case NotificationType.bookingReminder:
        return Icons.alarm_rounded;
      case NotificationType.bookingCancelled:
        return Icons.cancel_rounded;
      case NotificationType.paymentReceived:
        return Icons.payment_rounded;
      case NotificationType.paymentFailed:
        return Icons.error_rounded;
      case NotificationType.refundProcessed:
        return Icons.currency_exchange_rounded;
      case NotificationType.reviewReceived:
        return Icons.star_rounded;
      case NotificationType.messageReceived:
        return Icons.message_rounded;
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.system:
        return Icons.settings_rounded;
      case NotificationType.parkingUnavailable:
        return Icons.local_parking_rounded;
      case NotificationType.hostResponse:
        return Icons.person_rounded;
      case NotificationType.specialOffer:
        return Icons.card_giftcard_rounded;
    }
  }

  // Get color for each type
  Color get color {
    switch (this) {
      case NotificationType.bookingConfirmed:
      case NotificationType.paymentReceived:
      case NotificationType.refundProcessed:
        return Colors.green;
      case NotificationType.bookingReminder:
        return Colors.orange;
      case NotificationType.bookingCancelled:
      case NotificationType.paymentFailed:
        return Colors.red;
      case NotificationType.reviewReceived:
        return Colors.amber;
      case NotificationType.messageReceived:
        return Colors.blue;
      case NotificationType.promotion:
      case NotificationType.specialOffer:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.parkingUnavailable:
        return Colors.red.shade700;
      case NotificationType.hostResponse:
        return Colors.teal;
    }
  }

  // Get title prefix
  String get titlePrefix {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case NotificationType.bookingReminder:
        return 'Reminder';
      case NotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case NotificationType.paymentReceived:
        return 'Payment Received';
      case NotificationType.paymentFailed:
        return 'Payment Failed';
      case NotificationType.refundProcessed:
        return 'Refund Processed';
      case NotificationType.reviewReceived:
        return 'New Review';
      case NotificationType.messageReceived:
        return 'New Message';
      case NotificationType.promotion:
        return 'Special Offer';
      case NotificationType.system:
        return 'System Update';
      case NotificationType.parkingUnavailable:
        return 'Parking Unavailable';
      case NotificationType.hostResponse:
        return 'Host Response';
      case NotificationType.specialOffer:
        return 'Exclusive Offer';
    }
  }

  String toJson() => name.toUpperCase();
}

enum NotificationChannel {
  push,
  email,
  inApp;

  static NotificationChannel fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationChannel.push,
    );
  }

  String toJson() => name.toUpperCase();
}

enum ReportTargetType {
  user,
  parkingSpot,
  review;

  static ReportTargetType fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ReportTargetType.user,
    );
  }

  String toJson() => name.toUpperCase();
}

enum ReportReason {
  fakeListing,
  spam,
  inappropriate,
  fraud,
  wrongLocation;

  static ReportReason fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ReportReason.fakeListing,
    );
  }

  String toJson() => name.toUpperCase();
}

enum ReportStatus {
  pending,
  resolved,
  dismissed;

  static ReportStatus fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ReportStatus.pending,
    );
  }

  String toJson() => name.toUpperCase();
}
