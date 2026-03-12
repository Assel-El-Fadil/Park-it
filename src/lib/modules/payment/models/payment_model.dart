import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingBooking {
  final String parkingName;
  final String location;
  final DateTime startTime;
  final LatLng coordinates;
  final DateTime endTime;
  final double pricePerHour;
  final double totalHours;
  final String? parkingImage;
  final String hostName;
  final double hostRating;

  ParkingBooking({
    required this.parkingName,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.totalHours,
    required this.coordinates,
    this.parkingImage,
    required this.hostName,
    required this.hostRating,
  });

  double get subtotal => pricePerHour * totalHours;
  double get serviceFee => subtotal * 0.10;
  double get total => subtotal + serviceFee;
}

class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final String expiryDate;
  final String cardHolderName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.expiryDate,
    required this.cardHolderName,
    this.isDefault = false,
  });

  String get displayName => '•••• $last4';
  IconData get icon {
    switch (type.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      case 'paypal':
        return Icons.paypal;
      default:
        return Icons.credit_card;
    }
  }
}
