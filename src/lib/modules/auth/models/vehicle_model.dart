enum VehicleType {
  car,
  van,
  motorcycle,
  truck,
  electric,
}

class VehicleModel {
  final String id;
  final String ownerId;
  final VehicleType type;
  final String brand;
  final String model;
  final String? color;
  final String plateNumber;
  final bool isDefault;
  final bool active;

  const VehicleModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.brand,
    required this.model,
    this.color,
    required this.plateNumber,
    this.isDefault = false,
    this.active = true,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      type: _typeFromString(json['type'] as String?),
      brand: json['brand'] as String,
      model: json['model'] as String,
      color: json['color'] as String?,
      plateNumber: json['plateNumber'] as String,
      isDefault: json['default'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
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
      'default': isDefault,
      'active': active,
    };
  }

  Map<String, dynamic> toVehicleRow() {
    return <String, dynamic>{
      'id': id,
      'owner_id': ownerId,
      'type': type.name,
      'brand': brand,
      'model': model,
      'color': color,
      'plate_number': plateNumber,
      'default': isDefault,
      'active': active,
    };
  }

  factory VehicleModel.fromVehicleRow(Map<String, dynamic> row) {
    return VehicleModel(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      type: _typeFromString(row['type'] as String?),
      brand: row['brand'] as String,
      model: row['model'] as String,
      color: row['color'] as String?,
      plateNumber: row['plate_number'] as String,
      isDefault: row['default'] as bool? ?? false,
      active: row['active'] as bool? ?? true,
    );
  }

  VehicleModel copyWith({
    String? id,
    String? ownerId,
    VehicleType? type,
    String? brand,
    String? model,
    String? color,
    String? plateNumber,
    bool? isDefault,
    bool? active,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      plateNumber: plateNumber ?? this.plateNumber,
      isDefault: isDefault ?? this.isDefault,
      active: active ?? this.active,
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
