// lib/core/enums/user_enums.dart

import 'package:flutter/material.dart';

enum UserRole {
  driver,
  owner,
  admin,
  superAdmin;

  static UserRole fromString(String value) {
    final normalized = value.toUpperCase();
    switch (normalized) {
      case 'OWNER':
        return UserRole.owner;
      case 'ADMIN':
        return UserRole.admin;
      case 'SUPER_ADMIN':
      case 'SUPERADMIN':
        return UserRole.superAdmin;
      case 'DRIVER':
      default:
        return UserRole.driver;
    }
  }

  String toJson() {
    return switch (this) {
      UserRole.driver => 'DRIVER',
      UserRole.owner => 'OWNER',
      UserRole.admin => 'ADMIN',
      UserRole.superAdmin => 'SUPER_ADMIN',
    };
  }
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
  occupied,
  reserved,
  maintenance,
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
    final normalized = value.toUpperCase();
    switch (normalized) {
      case 'EV_CHARGER':
      case 'EVCHARGER':
        return Amenity.evCharger;
      case 'CAR_WASH':
      case 'CARWASH':
        return Amenity.carWash;
      case 'CCTV':
        return Amenity.cctv;
      case 'LIGHTING':
        return Amenity.lighting;
      case 'WHEELCHAIR':
        return Amenity.wheelchair;
      case 'GUARD':
        return Amenity.guard;
      default:
        return Amenity.cctv;
    }
  }

  String toJson() {
    return switch (this) {
      Amenity.cctv => 'CCTV',
      Amenity.lighting => 'LIGHTING',
      Amenity.evCharger => 'EV_CHARGER',
      Amenity.wheelchair => 'WHEELCHAIR',
      Amenity.guard => 'GUARD',
      Amenity.carWash => 'CAR_WASH',
    };
  }
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
  idle,
  loading,
  pending,
  cancelled,
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
    final normalized = value.replaceAll('_', '').toUpperCase();
    return values.firstWhere(
      (e) => e.name.toUpperCase() == normalized,
      orElse: () => ReportTargetType.user,
    );
  }

  String toJson() {
    return switch (this) {
      ReportTargetType.user => 'USER',
      ReportTargetType.parkingSpot => 'PARKING_SPOT',
      ReportTargetType.review => 'REVIEW',
    };
  }
}

enum ReportReason {
  fakeListing,
  spam,
  inappropriate,
  fraud,
  wrongLocation;

  static ReportReason fromString(String value) {
    final normalized = value.replaceAll('_', '').toUpperCase();
    return values.firstWhere(
      (e) => e.name.toUpperCase() == normalized,
      orElse: () => ReportReason.fakeListing,
    );
  }

  String toJson() {
    return switch (this) {
      ReportReason.fakeListing => 'FAKE_LISTING',
      ReportReason.spam => 'SPAM',
      ReportReason.inappropriate => 'INAPPROPRIATE',
      ReportReason.fraud => 'FRAUD',
      ReportReason.wrongLocation => 'WRONG_LOCATION',
    };
  }
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

// lib/services/navigation_service.dart (or create a separate file)

/// Error types for navigation operations
enum NavigationError {
  /// Location services are disabled on the device
  locationServicesDisabled,

  /// User denied location permission
  permissionDenied,

  /// User permanently denied location permission
  permissionDeniedForever,

  /// Could not get current location
  locationNotFound,

  /// No map applications are installed on the device
  mapsNotAvailable,

  /// Network connectivity issues
  networkError,

  /// Invalid coordinates provided
  invalidCoordinates,

  /// Navigation not available for this reservation (too early/late)
  navigationNotAvailable,

  /// Timeout while getting location
  locationTimeout,

  /// Unknown error occurred
  unknown,
}

// Extension for user-friendly error messages
extension NavigationErrorExtension on NavigationError {
  String get userMessage {
    switch (this) {
      case NavigationError.locationServicesDisabled:
        return 'Location services are disabled. Please enable them to navigate.';
      case NavigationError.permissionDenied:
        return 'Location permission is needed to show directions.';
      case NavigationError.permissionDeniedForever:
        return 'Location permission is permanently denied. Please enable it in app settings.';
      case NavigationError.locationNotFound:
        return 'Could not get your current location. Please try again.';
      case NavigationError.mapsNotAvailable:
        return 'No map applications found on your device.';
      case NavigationError.networkError:
        return 'Network error. Please check your internet connection.';
      case NavigationError.invalidCoordinates:
        return 'Invalid parking spot coordinates.';
      case NavigationError.navigationNotAvailable:
        return 'Navigation is not available for this reservation at this time.';
      case NavigationError.locationTimeout:
        return 'Location request timed out. Please try again.';
      case NavigationError.unknown:
        return 'An unknown error occurred. Please try again.';
    }
  }

  // Get error title for dialogs
  String get title {
    switch (this) {
      case NavigationError.locationServicesDisabled:
        return 'Location Services Disabled';
      case NavigationError.permissionDenied:
      case NavigationError.permissionDeniedForever:
        return 'Location Permission Required';
      case NavigationError.locationNotFound:
        return 'Location Not Found';
      case NavigationError.mapsNotAvailable:
        return 'No Maps Available';
      case NavigationError.networkError:
        return 'Network Error';
      case NavigationError.invalidCoordinates:
        return 'Invalid Location';
      case NavigationError.navigationNotAvailable:
        return 'Navigation Unavailable';
      case NavigationError.locationTimeout:
        return 'Location Timeout';
      case NavigationError.unknown:
        return 'Error';
    }
  }

  // Get icon for error
  IconData get icon {
    switch (this) {
      case NavigationError.locationServicesDisabled:
      case NavigationError.permissionDenied:
      case NavigationError.permissionDeniedForever:
        return Icons.location_off;
      case NavigationError.locationNotFound:
        return Icons.location_searching;
      case NavigationError.mapsNotAvailable:
        return Icons.map;
      case NavigationError.networkError:
        return Icons.wifi_off;
      case NavigationError.invalidCoordinates:
        return Icons.location_disabled;
      case NavigationError.navigationNotAvailable:
        return Icons.timer_off;
      case NavigationError.locationTimeout:
        return Icons.timer_off;
      case NavigationError.unknown:
        return Icons.error_outline;
    }
  }

  // Check if error is recoverable
  bool get isRecoverable {
    switch (this) {
      case NavigationError.locationServicesDisabled:
      case NavigationError.permissionDenied:
      case NavigationError.permissionDeniedForever:
      case NavigationError.networkError:
      case NavigationError.locationTimeout:
        return true;
      case NavigationError.locationNotFound:
      case NavigationError.mapsNotAvailable:
      case NavigationError.invalidCoordinates:
      case NavigationError.navigationNotAvailable:
      case NavigationError.unknown:
        return false;
    }
  }

  // Get suggested action for user
  String? get suggestedAction {
    switch (this) {
      case NavigationError.locationServicesDisabled:
        return 'Open Settings';
      case NavigationError.permissionDenied:
        return 'Request Permission';
      case NavigationError.permissionDeniedForever:
        return 'Open App Settings';
      case NavigationError.networkError:
        return 'Retry';
      case NavigationError.locationTimeout:
        return 'Try Again';
      default:
        return null;
    }
  }
}
