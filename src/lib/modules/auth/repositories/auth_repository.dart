import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/services/auth_service.dart';
import 'package:src/modules/auth/services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<bool> signInWithOAuth(OAuthProvider provider);

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
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _authService.signInWithOAuth(provider);
      return true;
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  Future<UserModel?> _upsertOAuthUser(User supabaseUser) async {
    final email = supabaseUser.email ?? supabaseUser.phone ?? '';
    if (email.isEmpty) return null;

    final existing = await client
        .from(tableName)
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      return UserModel.fromSupabaseUser(
        supabaseUser,
        existing as Map<String, dynamic>,
      );
    }

    final metadata = supabaseUser.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        supabaseUser.email ?? '';
    final parts = fullName.split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final inserted = await client.from(tableName).insert({
      'first_name': firstName.isNotEmpty ? firstName : 'User',
      'last_name': lastName.isNotEmpty ? lastName : '',
      'email': email,
      'phone': supabaseUser.phone,
      'profile_photo': metadata['avatar_url'] as String?,
      'average_rating': 0,
      'total_reviews': 0,
      'fcm_token': null,
      'role': 'DRIVER',
    }).select().maybeSingle();

    if (inserted == null) return null;
    return UserModel.fromUserRow(inserted as Map<String, dynamic>);
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  ) async {
    try {
      // Pass profile fields as auth metadata — no INSERT into users table needed,
      // so RLS is never triggered.
      final response = await _authService.signUp(
        email,
        password,
        firstName: firstName,
        lastName: lastName,
        role: role.name.toUpperCase(),
      );
      final user = response.user;
      if (user == null) {
        throw AppException(AppConstants.errorGeneric);
      }

      // Build the model from auth metadata — no DB read required.
      final meta = user.userMetadata ?? {};
      final userModel = UserModel(
        id: user.id,
        firstName: meta['first_name'] as String? ?? firstName,
        lastName: meta['last_name'] as String? ?? lastName,
        email: user.email ?? email,
        role: role,
      );

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

      // Try reading from users table first; fall back to auth metadata.
      UserModel userModel;
      try {
        final userRow = await client
            .from(tableName)
            .select()
            .eq('email', user.email ?? '')
            .maybeSingle();

        if (userRow != null) {
          userModel = UserModel.fromSupabaseUser(
            user,
            userRow as Map<String, dynamic>,
          );
        } else {
          final meta = user.userMetadata ?? {};
          userModel = UserModel(
            id: user.id,
            firstName: meta['first_name'] as String? ?? '',
            lastName: meta['last_name'] as String? ?? '',
            email: user.email ?? email,
            role: _roleFromMeta(meta['role'] as String?),
          );
        }
      } on PostgrestException {
        // users table unreachable — build from metadata
        final meta = user.userMetadata ?? {};
        userModel = UserModel(
          id: user.id,
          firstName: meta['first_name'] as String? ?? '',
          lastName: meta['last_name'] as String? ?? '',
          email: user.email ?? email,
          role: _roleFromMeta(meta['role'] as String?),
        );
      }

      final token = response.session?.accessToken;
      if (token != null) {
        await _sessionService.saveSession(userModel, token);
      }
      return userModel;
    } on AuthException catch (e) {
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

      // Try users table; gracefully fall back to auth metadata on RLS/error.
      try {
        final userRow = await client
            .from(tableName)
            .select()
            .eq('email', user.email ?? user.phone ?? '')
            .maybeSingle();

        if (userRow != null) {
          final model = UserModel.fromSupabaseUser(
            user,
            userRow as Map<String, dynamic>,
          );
          final token = _authService.getAccessToken();
          if (token != null) {
            await _sessionService.saveSession(model, token);
          }
          return model;
        }
      } on PostgrestException {
        // Fall through to metadata fallback
      }

      // Build from auth metadata (used when users table row doesn't exist yet)
      final meta = user.userMetadata ?? {};
      if (meta.isNotEmpty) {
        final model = UserModel(
          id: user.id,
          firstName: meta['first_name'] as String? ?? '',
          lastName: meta['last_name'] as String? ?? '',
          email: user.email ?? '',
          role: _roleFromMeta(meta['role'] as String?),
        );
        final token = _authService.getAccessToken();
        if (token != null) {
          await _sessionService.saveSession(model, token);
        }
        return model;
      }

      return null;
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

  UserRole _roleFromMeta(String? roleStr) {
    if (roleStr == null) return UserRole.driver;
    if (roleStr.toUpperCase() == 'OWNER') return UserRole.owner;
    return UserRole.driver;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authServiceProvider),
    ref.watch(sessionServiceProvider),
  );
});
