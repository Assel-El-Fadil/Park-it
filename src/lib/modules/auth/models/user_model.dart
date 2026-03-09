import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole {
  driver,
  owner,
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profilePhoto;
  final double averageRating;
  final int totalReviews;
  final String? fcmToken;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profilePhoto,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.fcmToken,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      fcmToken: json['fcmToken'] as String?,
      role: _roleFromString(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profilePhoto': profilePhoto,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'fcmToken': fcmToken,
      'role': role.name,
    };
  }

  Map<String, dynamic> toProfileRow() {
    return <String, dynamic>{
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_photo': profilePhoto,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'fcm_token': fcmToken,
      'role': role.name,
    };
  }

  factory UserModel.fromSupabaseUser(
    User user,
    Map<String, dynamic> profileData,
  ) {
    return UserModel(
      id: user.id,
      firstName: (profileData['first_name'] as String?) ?? '',
      lastName: (profileData['last_name'] as String?) ?? '',
      email: user.email ?? (profileData['email'] as String? ?? ''),
      phone: (profileData['phone'] as String?) ?? user.phone,
      profilePhoto: profileData['profile_photo'] as String?,
      averageRating:
          (profileData['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: profileData['total_reviews'] as int? ?? 0,
      fcmToken: profileData['fcm_token'] as String?,
      role: _roleFromString(profileData['role'] as String?),
    );
  }

  factory UserModel.fromProfileRow(Map<String, dynamic> profileData) {
    return UserModel(
      id: profileData['id'] as String,
      firstName: (profileData['first_name'] as String?) ?? '',
      lastName: (profileData['last_name'] as String?) ?? '',
      email: (profileData['email'] as String?) ?? '',
      phone: profileData['phone'] as String?,
      profilePhoto: profileData['profile_photo'] as String?,
      averageRating:
          (profileData['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: profileData['total_reviews'] as int? ?? 0,
      fcmToken: profileData['fcm_token'] as String?,
      role: _roleFromString(profileData['role'] as String?),
    );
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profilePhoto,
    double? averageRating,
    int? totalReviews,
    String? fcmToken,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      fcmToken: fcmToken ?? this.fcmToken,
      role: role ?? this.role,
    );
  }
}

UserRole _roleFromString(String? value) {
  switch (value) {
    case 'owner':
      return UserRole.owner;
    case 'driver':
    default:
      return UserRole.driver;
  }
}

