class WishlistModel {
  final int id;
  final String userId;
  final int spotId;
  final DateTime addedAt;

  WishlistModel({
    required this.id,
    required this.userId,
    required this.spotId,
    required this.addedAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      spotId: json['spot_id'] as int,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'spot_id': spotId,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
