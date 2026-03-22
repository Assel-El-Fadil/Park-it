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
  UserModel fromJson(Map<String, dynamic> json) => UserModel.fromUserRow(json);

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

  Future<UserModel> _getOrCreateUser(User supabaseUser) async {
    final email = supabaseUser.email ?? supabaseUser.phone ?? '';
    
    // 1. Try to find existing
    final existing = await client
        .from(tableName)
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      return UserModel.fromSupabaseUser(supabaseUser, existing);
    }

    // 2. Create if missing
    final metadata = supabaseUser.userMetadata ?? {};
    final fullName =
        metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        metadata['first_name'] as String? ??
        'User';
    
    final inserted = await client
        .from(tableName)
        .insert({
          'first_name': metadata['first_name'] as String? ?? fullName.split(' ').first,
          'last_name': metadata['last_name'] as String? ?? (fullName.contains(' ') ? fullName.split(' ').sublist(1).join(' ') : ''),
          'email': email,
          'role': (metadata['role'] as String?)?.toUpperCase() ?? 'DRIVER',
          'average_rating': 0,
          'total_reviews': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return UserModel.fromUserRow(inserted);
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
      // 1. Create the Auth User
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

      // 2. Insert into public.users table to get an integer ID
      final userRow = await client
          .from('users')
          .insert({
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'role': role.name.toUpperCase(),
            'average_rating': 0,
            'total_reviews': 0,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final userModel = UserModel.fromSupabaseUser(user, userRow);

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

      final userModel = await _getOrCreateUser(user);

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
      await client
          .from(tableName)
          .update({
            'first_name': user.firstName,
            'last_name': user.lastName,
            'email': user.email,
            'phone': user.phone,
            'profile_photo': user.profilePhoto,
            'average_rating': user.averageRating,
            'total_reviews': user.totalReviews,
            'fcm_token': user.fcmToken,
            'role': user.role.name.toUpperCase(),
          })
          .eq('id', int.tryParse(user.id) ?? -1);
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

      final userModel = await _getOrCreateUser(user);
      
      final token = _authService.getAccessToken();
      if (token != null) {
        await _sessionService.saveSession(userModel, token);
      }
      return userModel;
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

        return UserModel.fromSupabaseUser(user, userRow);
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
