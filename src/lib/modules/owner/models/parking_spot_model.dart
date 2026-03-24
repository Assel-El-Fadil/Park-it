import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/navigation/models/spot_model.dart';

class ParkingSpotModel {
  final int id;
  final String ownerId;
  final int? lotId;
  final String title;
  final String? description;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final String? street;
  final String? city;
  final String? country;
  final String? postalCode;
  final List<String>? photos;
  final double pricePerHour;
  final double? pricePerDay;
  final SpotType spotType;
  final List<VehicleType>? vehicleTypes;
  final List<Amenity>? amenities;
  final SpotStatus status;
  final double averageRating;
  final int totalReviews;
  final int totalBookings;
  final bool isDynamicPricing;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingSpotModel({
    required this.id,
    required this.ownerId,
    this.lotId,
    required this.title,
    this.description,
    this.latitude,
    this.longitude,
    this.altitude,
    this.street,
    this.city,
    this.country,
    this.postalCode,
    this.photos,
    required this.pricePerHour,
    this.pricePerDay,
    required this.spotType,
    this.vehicleTypes,
    this.amenities,
    required this.status,
    required this.averageRating,
    required this.totalReviews,
    required this.totalBookings,
    required this.isDynamicPricing,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParkingSpotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpotModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as String,
      lotId: json['lot_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      street: json['street'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : null,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      pricePerDay: json['price_per_day'] != null
          ? (json['price_per_day'] as num).toDouble()
          : null,
      spotType: SpotType.fromString(json['spot_type'] as String),
      vehicleTypes: json['vehicle_types'] != null
          ? (json['vehicle_types'] as List)
                .map((e) => VehicleType.fromString(e as String))
                .toList()
          : null,
      amenities: json['amenities'] != null
          ? (json['amenities'] as List)
                .map((e) => Amenity.fromString(e as String))
                .toList()
          : null,
      status: SpotStatus.fromString(json['status'] as String),
      averageRating: json['average_rating'] != null ? (json['average_rating'] as num).toDouble() : 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
      isDynamicPricing: json['is_dynamic_pricing'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  SpotModel toSpotModel() => SpotModel(
    id: id.toString(),
    name: title,
    latitude: latitude!,
    longitude: longitude!,
    imageUrl: photos?.firstOrNull,
    description: description,
    category: spotType.toJson(),
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'lot_id': lotId,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'street': street,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'photos': photos,
      'price_per_hour': pricePerHour,
      'price_per_day': pricePerDay,
      'spot_type': spotType.toJson(),
      'vehicle_types': vehicleTypes?.map((e) => e.toJson()).toList(),
      'amenities': amenities?.map((e) => e.toJson()).toList(),
      'status': status.toJson(),
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'total_bookings': totalBookings,
      'is_dynamic_pricing': isDynamicPricing,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
