import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<UserModel> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  );

  Future<UserModel> signIn(String email, String password);

  Future<void> signOut();

  Future<void> updateProfile(UserModel user);

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateStream;
}

class AuthRepositoryImpl extends SupabaseRepository<UserModel>
    implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;

  @override
  String get tableName => 'profiles';

  @override
  Map<String, dynamic> toJson(UserModel item) => item.toProfileRow();

  @override
  UserModel fromJson(Map<String, dynamic> json) =>
      UserModel.fromProfileRow(json);

  @override
  String getItemKey(UserModel item) => item.id;

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  ) async {
    try {
      final response = await _authService.signUp(email, password);
      final user = response.user;
      if (user == null) {
        throw AppException(AppConstants.errorGeneric);
      }

      await client.from(tableName).insert({
        'id': user.id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': null,
        'profile_photo': null,
        'role': role.name,
      });

      final profile = await client
          .from(tableName)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        throw AppException(AppConstants.errorGeneric);
      }

      return UserModel.fromProfileRow(profile as Map<String, dynamic>);
    } on AuthException catch (e) {
      throw AppException(e.message);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _authService.signIn(email, password);
      final user = response.user;
      if (user == null) {
        throw AppException(AppConstants.errorInvalidCredentials);
      }

      final profile = await client
          .from(tableName)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        throw AppException(AppConstants.errorUserNotFound);
      }

      return UserModel.fromSupabaseUser(
        user,
        profile as Map<String, dynamic>,
      );
    } on AuthException catch (e) {
      throw AppException(e.message);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    try {
      await client.from(tableName).update({
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email,
        'phone': user.phone,
        'profile_photo': user.profilePhoto,
        'average_rating': user.averageRating,
        'total_reviews': user.totalReviews,
        'fcm_token': user.fcmToken,
        'role': user.role.name,
      }).eq('id', user.id);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return null;

      final profile = await client
          .from(tableName)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) return null;

      return UserModel.fromSupabaseUser(
        user,
        profile as Map<String, dynamic>,
      );
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateStream {
    return _authService.authStateStream.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user == null) return null;

      try {
        final profile = await client
            .from(tableName)
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null) return null;

        return UserModel.fromSupabaseUser(
          user,
          profile as Map<String, dynamic>,
        );
      } catch (_) {
        return null;
      }
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authServiceProvider));
});
