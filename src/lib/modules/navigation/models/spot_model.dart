import 'package:src/modules/navigation/models/location_model.dart';

class SpotModel {
  const SpotModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.description,
    this.category,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? description;
  final String? category;

  factory SpotModel.fromJson(Map<String, dynamic> json) => SpotModel(
    id: json['id'] as String,
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    imageUrl: json['image_url'] as String?,
    description: json['description'] as String?,
    category: json['category'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'image_url': imageUrl,
    'description': description,
    'category': category,
  };

  LocationModel toLocationModel() =>
      LocationModel(latitude: latitude, longitude: longitude);

  SpotModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? description,
    String? category,
  }) => SpotModel(
    id: id ?? this.id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    imageUrl: imageUrl ?? this.imageUrl,
    description: description ?? this.description,
    category: category ?? this.category,
  );

  @override
  bool operator ==(Object other) => other is SpotModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SpotModel(id: $id, name: $name, '
      'lat: $latitude, lng: $longitude)';
}
