import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/services/auth_service.dart';
import 'package:src/modules/auth/services/session_service.dart';
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
  AuthRepositoryImpl(this._authService, this._sessionService);

  final AuthService _authService;
  final SessionService _sessionService;

  @override
  String get tableName => 'users';

  @override
  Map<String, dynamic> toJson(UserModel item) => item.toUserRow();

  @override
  UserModel fromJson(Map<String, dynamic> json) =>
      UserModel.fromUserRow(json);

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

      final inserted = await client.from(tableName).insert({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': null,
        'profile_photo': null,
        'average_rating': 0,
        'total_reviews': 0,
        'fcm_token': null,
        'role': role.name.toUpperCase(),
      }).select().maybeSingle();

      if (inserted == null) {
        throw AppException(AppConstants.errorGeneric);
      }

      final userModel =
          UserModel.fromUserRow(inserted as Map<String, dynamic>);
      final token = response.session?.accessToken;
      if (token != null) {
        await _sessionService.saveSession(userModel, token);
      }
      return userModel;
    } on AuthException catch (e, stackTrace) {
      print('ERROR [AuthRepositoryImpl.signUp]: $e');
      print('STACK [AuthRepositoryImpl.signUp]: $stackTrace');
      throw AppException(e.message);
    } on PostgrestException catch (e, stackTrace) {
      print('ERROR [AuthRepositoryImpl.signUp]: $e');
      print('STACK [AuthRepositoryImpl.signUp]: $stackTrace');
      throw AppException(e.message);
    } catch (e, stackTrace) {
      print('ERROR [AuthRepositoryImpl.signUp]: $e');
      print('STACK [AuthRepositoryImpl.signUp]: $stackTrace');
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

      final userRow = await client
          .from(tableName)
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();

      if (userRow == null) {
        throw AppException(AppConstants.errorUserNotFound);
      }

      final userModel = UserModel.fromSupabaseUser(
        user,
        userRow as Map<String, dynamic>,
      );
      final token = response.session?.accessToken;
      if (token != null) {
        await _sessionService.saveSession(userModel, token);
      }
      return userModel;
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
      await _sessionService.clearSession();
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
        'role': user.role.name.toUpperCase(),
      }).eq('id', int.tryParse(user.id) ?? -1);
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

      final userRow = await client
          .from(tableName)
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();

      if (userRow == null) return null;

      return UserModel.fromSupabaseUser(
        user,
        userRow as Map<String, dynamic>,
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
        final userRow = await client
            .from(tableName)
            .select()
            .eq('email', user.email ?? '')
            .maybeSingle();

        if (userRow == null) return null;

        return UserModel.fromSupabaseUser(
          user,
          userRow as Map<String, dynamic>,
        );
      } catch (_) {
        return null;
      }
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authServiceProvider),
    ref.watch(sessionServiceProvider),
  );
});
