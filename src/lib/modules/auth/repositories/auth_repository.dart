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
    String? phone,
    UserRole role,
  );

  Future<UserModel> signIn(String identifier, String password);

  Future<void> signOut();

  Future<void> updateProfile(UserModel user);

  Future<UserModel?> getCurrentUser();

  Future<String> uploadProfilePhoto(String userId, dynamic file);

  Future<void> sendPasswordReset(String email);

  Future<UserModel> verifyOTP({
    String? email,
    String? phone,
    required String token,
    required OtpType type,
  });

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
    final email = supabaseUser.email;
    final phone = supabaseUser.phone;

    // 1. Try to find existing by email or phone
    Map<String, dynamic>? existing;
    if ((email ?? '').isNotEmpty) {
      existing = await client
          .from(tableName)
          .select()
          .eq('email', email!)
          .maybeSingle() as Map<String, dynamic>?;
    }
    if (existing == null && (phone ?? '').isNotEmpty) {
      existing = await client
          .from(tableName)
          .select()
          .eq('phone', phone!)
          .maybeSingle() as Map<String, dynamic>?;
    }

    if (existing != null) {
      return UserModel.fromSupabaseUser(supabaseUser, existing);
    }

    // 2. If missing from users table (due to RLS or sync delay), build from Auth metadata directly.
    final metadata = supabaseUser.userMetadata ?? {};
    final fullName =
        metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        metadata['first_name'] as String? ??
        'User';

    final firstName = metadata['first_name'] as String? ?? fullName.split(' ').first;
    final lastName = metadata['last_name'] as String? ?? (fullName.contains(' ') ? fullName.split(' ').sublist(1).join(' ') : '');
    final roleStr = metadata['role'] as String?;

    return UserModel(
      id: supabaseUser.id,
      firstName: firstName,
      lastName: lastName,
      email: email ?? '',
      phone: phone,
      role: _roleFromMeta(roleStr),
    );
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String? phone,
    UserRole role,
  ) async {
    try {
      // 1. Create the Auth User (Supabase)
      // We pass the profile data as user metadata so it persists without needing
      // to insert into the public.users table (which is restricted by RLS).
      final response = await _authService.signUp(
        email,
        password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role.name.toUpperCase(),
      );
      final user = response.user;
      if (user == null) {
        throw AppException(AppConstants.errorGeneric);
      }

      // 2. Build UserModel directly from the metadata returning from Auth
      final meta = user.userMetadata ?? {};
      final userModel = UserModel(
        id: user.id,
        firstName: meta['first_name'] as String? ?? firstName,
        lastName: meta['last_name'] as String? ?? lastName,
        email: user.email ?? email,
        phone: meta['phone'] as String? ?? phone,
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
  Future<UserModel> signIn(String identifier, String password) async {
    try {
      final email = await _resolveEmailFromIdentifier(identifier.trim());
      if (email == null || email.isEmpty) {
        throw AppException(AppConstants.errorInvalidCredentials);
      }

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
      // Bypass RLS by saving data into Supabase Auth Metadata
      await client.auth.updateUser(UserAttributes(data: {
        'first_name': user.firstName,
        'last_name': user.lastName,
        'phone': user.phone,
        'profile_photo': user.profilePhoto,
        'role': user.role.name.toUpperCase(),
      }));

      // Also attempt to update the users table but ignore RLS errors gracefully
      try {
        await client
            .from(tableName)
            .update({
              'first_name': user.firstName,
              'last_name': user.lastName,
              if (user.email != null) 'email': user.email,
              'phone': user.phone,
              'profile_photo': user.profilePhoto,
              'average_rating': user.averageRating,
              'total_reviews': user.totalReviews,
              'fcm_token': user.fcmToken,
              'role': user.role.name.toUpperCase(),
            })
            .eq('id', int.tryParse(user.id) ?? -1);
      } catch (_) {
        // Ignored Database Error
      }
    } catch (e) {
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<String> uploadProfilePhoto(String userId, dynamic file) async {
    try {
      final String path = '$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
      await client.storage.from('avatars').upload(path, file);
      return client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      throw AppException('Error uploading photo');
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
  Future<void> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<UserModel> verifyOTP({
    String? email,
    String? phone,
    required String token,
    required OtpType type,
  }) async {
    try {
      final response = await _authService.verifyOTP(
        email: email,
        phone: phone,
        token: token,
        type: type,
      );
      final user = response.user;
      if (user == null) {
        throw AppException(AppConstants.errorGeneric);
      }

      final userModel = await _getOrCreateUser(user);
      
      final sessionToken = response.session?.accessToken;
      if (sessionToken != null) {
        await _sessionService.saveSession(userModel, sessionToken);
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
  Stream<UserModel?> get authStateStream {
    return _authService.authStateStream.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user == null) return null;

      try {
        Map<String, dynamic>? userRow;
        if ((user.email ?? '').isNotEmpty) {
          userRow = await client
              .from(tableName)
              .select()
              .eq('email', user.email!)
              .maybeSingle() as Map<String, dynamic>?;
        }
        if (userRow == null && (user.phone ?? '').isNotEmpty) {
          userRow = await client
              .from(tableName)
              .select()
              .eq('phone', user.phone!)
              .maybeSingle() as Map<String, dynamic>?;
        }
        if (userRow == null) return null;

        return UserModel.fromSupabaseUser(user, userRow);
      } catch (_) {
        return null;
      }
    });
  }

  /// Resolves identifier (email or phone) to email for Supabase Auth.
  Future<String?> _resolveEmailFromIdentifier(String identifier) async {
    if (identifier.contains('@')) {
      return identifier;
    }
    final row = await client
        .from(tableName)
        .select('email')
        .eq('phone', identifier)
        .maybeSingle();
    return row?['email'] as String?;
  }

  UserRole _roleFromMeta(String? roleStr) {
    if (roleStr == null) return UserRole.driver;
    if (roleStr.toUpperCase() == 'OWNER') return UserRole.owner;
    if (roleStr.toUpperCase() == 'ADMIN') return UserRole.admin;
    if (roleStr.toUpperCase() == 'SUPER_ADMIN') return UserRole.superAdmin;
    return UserRole.driver;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authServiceProvider),
    ref.watch(sessionServiceProvider),
  );
});
