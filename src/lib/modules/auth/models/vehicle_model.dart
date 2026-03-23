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

  const VehicleModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.brand,
    required this.model,
    this.color,
    required this.plateNumber,
    this.isDefault = false,
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

  Map<String, dynamic> toVehicleRow() {
    return <String, dynamic>{
      'owner_id': int.tryParse(ownerId) ?? ownerId,
      'type': type.name.toUpperCase(),
      'brand': brand,
      'model': model,
      'color': color ?? '',
      'plate_number': plateNumber,
      'is_default': isDefault,
    };
  }

  factory VehicleModel.fromVehicleRow(Map<String, dynamic> row) {
    return VehicleModel(
      id: row['id'].toString(),
      ownerId: row['owner_id'].toString(),
      type: _typeFromString(row['type'] as String?),
      brand: row['brand'] as String,
      model: row['model'] as String,
      color: row['color'] as String?,
      plateNumber: row['plate_number'] as String,
      isDefault: row['is_default'] as bool? ?? false,
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
    );
  }
}

VehicleType _typeFromString(String? value) {
  final v = (value ?? '').toLowerCase();
  switch (v) {
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
