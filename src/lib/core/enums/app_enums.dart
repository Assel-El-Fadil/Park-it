// lib/core/enums/user_enums.dart

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
}

enum NotificationType {
  reservationConfirmed,
  reservationCancelled,
  paymentSuccess,
  paymentFailed,
  reviewReceived,
  expiryReminder,
  accountVerified,
  disputeUpdate;

  static NotificationType fromString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationType.reservationConfirmed,
    );
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
