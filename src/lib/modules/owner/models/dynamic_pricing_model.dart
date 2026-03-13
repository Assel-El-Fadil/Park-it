class DynamicPricingRuleModel {
  final int id;
  final int spotId;
  final double? threeHours;
  final double? sixHours;
  final double? twelveHours;
  final bool isActive;

  DynamicPricingRuleModel({
    required this.id,
    required this.spotId,
    this.threeHours,
    this.sixHours,
    this.twelveHours,
    required this.isActive,
  });

  factory DynamicPricingRuleModel.fromJson(Map<String, dynamic> json) {
    return DynamicPricingRuleModel(
      id: json['id'] as int,
      spotId: json['spot_id'] as int,
      threeHours: json['three_hours'] != null
          ? (json['three_hours'] as num).toDouble()
          : null,
      sixHours: json['six_hours'] != null
          ? (json['six_hours'] as num).toDouble()
          : null,
      twelveHours: json['twelve_hours'] != null
          ? (json['twelve_hours'] as num).toDouble()
          : null,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spot_id': spotId,
      'three_hours': threeHours,
      'six_hours': sixHours,
      'twelve_hours': twelveHours,
      'is_active': isActive,
    };
  }

  double? getPriceForDuration(Duration duration) {
    final hours = duration.inHours;
    if (hours <= 3) return threeHours;
    if (hours <= 6) return sixHours;
    if (hours <= 12) return twelveHours;
    return null;
  }
}
