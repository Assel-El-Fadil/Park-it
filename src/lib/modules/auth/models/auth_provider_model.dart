class AuthProviderModel {
  final int id;
  final String userId;
  final String provider;
  final String providerUserId;
  final DateTime createdAt;

  AuthProviderModel({
    required this.id,
    required this.userId,
    required this.provider,
    required this.providerUserId,
    required this.createdAt,
  });

  factory AuthProviderModel.fromJson(Map<String, dynamic> json) {
    return AuthProviderModel(
      id: json['id'] as int,
      userId: json['user_id'].toString(),
      provider: json['provider'] as String,
      providerUserId: json['provider_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider': provider,
      'provider_user_id': providerUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
