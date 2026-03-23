import 'vehicle_model.dart';

class VehicleDTO {
  final String id;
  final String ownerId;
  final VehicleType type;
  final String brand;
  final String model;
  final String? color;
  final String plateNumber;
  final bool isDefault;

  const VehicleDTO({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.brand,
    required this.model,
    this.color,
    required this.plateNumber,
    this.isDefault = false,
  });

  factory VehicleDTO.fromJson(Map<String, dynamic> json) {
    return VehicleDTO(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      type: _typeFromString(json['type'] as String?),
      brand: json['brand'] as String,
      model: json['model'] as String,
      color: json['color'] as String?,
      plateNumber: json['plateNumber'] as String,
      isDefault: json['is_default'] as bool? ?? json['default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'type': type.name,
      'brand': brand,
      'model': model,
      'color': color,
      'plateNumber': plateNumber,
      'is_default': isDefault,
    };
  }

  VehicleModel toModel() {
    return VehicleModel(
      id: id,
      ownerId: ownerId,
      type: type,
      brand: brand,
      model: model,
      color: color,
      plateNumber: plateNumber,
      isDefault: isDefault,
    );
  }

  factory VehicleDTO.fromModel(VehicleModel model) {
    return VehicleDTO(
      id: model.id,
      ownerId: model.ownerId,
      type: model.type,
      brand: model.brand,
      model: model.model,
      color: model.color,
      plateNumber: model.plateNumber,
      isDefault: model.isDefault,
    );
  }
}

VehicleType _typeFromString(String? value) {
  switch (value) {
    case 'car':
      return VehicleType.car;
    case 'van':
      return VehicleType.van;
    case 'motorcycle':
      return VehicleType.motorcycle;
    case 'truck':
      return VehicleType.truck;
    case 'electric':
      return VehicleType.electric;
    default:
      return VehicleType.car;
  }
}
