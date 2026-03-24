import 'package:src/core/enums/app_enums.dart';

class ParkingLotModel {
  final int id;
  final String ownerId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double? altitude;
  final String street;
  final String city;
  final String country;
  final String postalCode;
  final List<String>? photos;
  final List<Amenity>? amenities;
  final int? totalSpots;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingLotModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
    this.photos,
    this.amenities,
    this.totalSpots,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParkingLotModel.fromJson(Map<String, dynamic> json) {
    return ParkingLotModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      street: json['street'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      postalCode: json['postal_code'] as String,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : null,
      amenities: json['amenities'] != null
          ? (json['amenities'] as List)
                .map((e) => Amenity.fromString(e as String))
                .toList()
          : null,
      totalSpots: json['total_spots'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'street': street,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'photos': photos,
      'amenities': amenities?.map((e) => e.toJson()).toList(),
      'total_spots': totalSpots,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullAddress => '$street, $city, $country $postalCode';
}
