// lib/models/user_model.dart

import 'package:src/core/enums/app_enums.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? passwordHash;
  final String? profilePhoto;
  final UserRole role;
  final VerificationStatus verificationStatus;
  final String? identityDoc;
  final bool isSuspended;
  final DateTime? suspensionAt;
  final DateTime? suspensionEnd;
  final bool isBanned;
  final double averageRating;
  final int totalReviews;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.passwordHash,
    this.profilePhoto,
    required this.role,
    required this.verificationStatus,
    this.identityDoc,
    required this.isSuspended,
    this.suspensionAt,
    this.suspensionEnd,
    required this.isBanned,
    required this.averageRating,
    required this.totalReviews,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      passwordHash: json['password_hash'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      role: UserRole.fromString(json['role'] as String),
      verificationStatus: VerificationStatus.fromString(
        json['verification_status'] as String,
      ),
      identityDoc: json['identity_doc'] as String?,
      isSuspended: json['is_suspended'] as bool,
      suspensionAt: json['suspension_at'] != null
          ? DateTime.parse(json['suspension_at'] as String)
          : null,
      suspensionEnd: json['suspension_end'] != null
          ? DateTime.parse(json['suspension_end'] as String)
          : null,
      isBanned: json['is_banned'] as bool,
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      fcmToken: json['fcm_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'profile_photo': profilePhoto,
      'role': role.toJson(),
      'verification_status': verificationStatus.toJson(),
      'identity_doc': identityDoc,
      'is_suspended': isSuspended,
      'suspension_at': suspensionAt?.toIso8601String(),
      'suspension_end': suspensionEnd?.toIso8601String(),
      'is_banned': isBanned,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
