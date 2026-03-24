import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { driver, owner, admin, superAdmin }

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
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
    this.email,
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
      email: json['email'] as String?,
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

  Map<String, dynamic> toUserRow() {
    return <String, dynamic>{
      'id': id.isEmpty ? null : id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email?.isNotEmpty == true ? email : null,
      'phone': phone?.isNotEmpty == true ? phone : null,
      'profile_photo': profilePhoto,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'fcm_token': fcmToken,
      'role': role.name.toUpperCase(),
    };
  }

  factory UserModel.fromSupabaseUser(
    User user,
    Map<String, dynamic> userRow,
  ) {
    final metadata = user.userMetadata ?? {};
    
    // Name: metadata first (updateUser), then DB.
    final String firstName = (metadata['first_name'] as String?) ?? (userRow['first_name'] as String?) ?? '';
    final String lastName = (metadata['last_name'] as String?) ?? (userRow['last_name'] as String?) ?? '';
    // Photo: DB first so a new `users` row after account deletion (null photo) is not
    // overridden by stale profile_photo still stored in Auth user_metadata.
    final String? rowPhoto = userRow['profile_photo'] as String?;
    final String? metaPhoto = metadata['profile_photo'] as String?;
    final String? profilePhoto = (rowPhoto != null && rowPhoto.trim().isNotEmpty)
        ? rowPhoto.trim()
        : (metaPhoto != null && metaPhoto.trim().isNotEmpty ? metaPhoto.trim() : null);

    return UserModel(
      id: (userRow['id'] ?? '').toString(),
      firstName: firstName,
      lastName: lastName,
      email: (userRow['email'] as String?) ?? user.email,
      phone: (metadata['phone'] as String?) ?? (userRow['phone'] as String?) ?? user.phone,
      profilePhoto: profilePhoto,
      averageRating:
          (userRow['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: userRow['total_reviews'] as int? ?? 0,
      fcmToken: (metadata['fcm_token'] as String?) ?? (userRow['fcm_token'] as String?),
      role: _roleFromString((metadata['role'] as String?) ?? (userRow['role'] as String?)),
    );
  }

  factory UserModel.fromUserRow(Map<String, dynamic> data) {
    return UserModel(
      id: (data['id'] ?? '').toString(),
      firstName: (data['first_name'] as String?) ?? '',
      lastName: (data['last_name'] as String?) ?? '',
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      profilePhoto: data['profile_photo'] as String?,
      averageRating:
          (data['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: data['total_reviews'] as int? ?? 0,
      fcmToken: data['fcm_token'] as String?,
      role: _roleFromString(data['role'] as String?),
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
  final normalized = (value ?? '').toUpperCase();
  switch (normalized) {
    case 'OWNER':
      return UserRole.owner;
    case 'ADMIN':
      return UserRole.admin;
    case 'SUPER_ADMIN':
    case 'SUPERADMIN':
      return UserRole.superAdmin;
    default:
      return UserRole.driver;
  }
}

