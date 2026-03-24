import 'package:src/core/enums/app_enums.dart';

class VehicleModel {
  final int id;
  final String ownerId;
  final String plateNumber;
  final VehicleType type;
  final String brand;
  final String model;
  final String color;
  final bool isDefault;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.ownerId,
    required this.plateNumber,
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.isDefault,
    required this.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      ownerId: json['owner_id'].toString(),
      plateNumber: json['plate_number'] as String,
      type: VehicleType.fromString(json['type'] as String),
      brand: json['brand'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'plate_number': plateNumber,
      'type': type.toJson(),
      'brand': brand,
      'model': model,
      'color': color,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
