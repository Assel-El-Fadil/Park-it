import 'user_model.dart';

class UserDTO {
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

  const UserDTO({
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

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
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

  UserModel toModel() {
    return UserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      profilePhoto: profilePhoto,
      averageRating: averageRating,
      totalReviews: totalReviews,
      fcmToken: fcmToken,
      role: role,
    );
  }

  factory UserDTO.fromModel(UserModel model) {
    return UserDTO(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      phone: model.phone,
      profilePhoto: model.profilePhoto,
      averageRating: model.averageRating,
      totalReviews: model.totalReviews,
      fcmToken: model.fcmToken,
      role: model.role,
    );
  }
}

UserRole _roleFromString(String? value) {
  final v = (value ?? '').toUpperCase();
  switch (v) {
    case 'OWNER':
      return UserRole.owner;
    case 'ADMIN':
      return UserRole.admin;
    case 'SUPER_ADMIN':
      return UserRole.superAdmin;
    default:
      return UserRole.driver;
  }
}

