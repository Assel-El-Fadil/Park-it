import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/constants/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<AuthResponse> signUp(
    String email,
    String password, {
    required String firstName,
    required String lastName,
    String? phone,
    required String role,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: AppConstants.authRedirectUrl('/login'),
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone?.trim().isNotEmpty == true ? phone!.trim() : null,
          'role': role,
        },
      );
    } on AuthException catch (e, stackTrace) {
      print('ERROR [AuthService.signUp]: $e');
      print('STACK [AuthService.signUp]: $stackTrace');
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('already been registered')) {
        throw AuthException(AppConstants.errorEmailInUse);
      }
      if (e.message.toLowerCase().contains('password') &&
          e.message.toLowerCase().contains('weak')) {
        throw AuthException(AppConstants.errorWeakPassword);
      }
      if (e.message.toLowerCase().contains('rate limit') ||
          e.statusCode == 429 ||
          e.statusCode?.toString() == '429' ||
          e.code == 'over_email_send_rate_limit') {
        throw AuthException(AppConstants.errorRateLimit);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e, stackTrace) {
      print('ERROR [AuthService.signUp]: $e');
      print('STACK [AuthService.signUp]: $stackTrace');
      if (e is AuthException) rethrow;
      final msg = e.toString().toLowerCase();
      if (msg.contains('rate limit') ||
          msg.contains('429') ||
          msg.contains('over_email_send_rate_limit')) {
        throw AuthException(AppConstants.errorRateLimit);
      }
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
      return true;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('credentials')) {
        throw AuthException(AppConstants.errorInvalidCredentials);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _client.auth.updateUser(UserAttributes(data: data));
    } on AuthException {
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  User? getCurrentUser() {
    try {
      return _client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  Stream<AuthState> get authStateStream {
    return _client.auth.onAuthStateChange;
  }

  String? getAccessToken() {
    try {
      return _client.auth.currentSession?.accessToken;
    } catch (e) {
      return null;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: AppConstants.authRedirectUrl('/reset-password'),
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('rate limit')) {
        throw AuthException(AppConstants.errorRateLimit);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<AuthResponse> verifyOTP({
    String? email,
    String? phone,
    required String token,
    required OtpType type,
  }) async {
    try {
      return await _client.auth.verifyOTP(
        email: email,
        phone: phone,
        token: token,
        type: type,
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<void> updatePassword({
    String? oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _client.auth.currentUser;
      
      // 1. Verify old password if provided
      if (oldPassword != null && oldPassword.isNotEmpty) {
        if (user == null || user.email == null) {
          throw AuthException('User must be logged in with an email to update password.');
        }
        await _client.auth.signInWithPassword(
          email: user.email!,
          password: oldPassword,
        );
      }

      // 2. If successful, update to the new password
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw AuthException('Le mot de passe actuel est incorrect.');
      }
      if (e.message.toLowerCase().contains('password') &&
          e.message.toLowerCase().contains('weak')) {
        throw AuthException(AppConstants.errorWeakPassword);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<void> updatePhone(String newPhone) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(phone: newPhone),
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('already been registered')) {
        throw AuthException('This phone number is already registered.');
      }
      if (e.message.toLowerCase().contains('rate limit')) {
        throw AuthException(AppConstants.errorRateLimit);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(email: newEmail),
        emailRedirectTo: AppConstants.authRedirectUrl('/profile'),
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('already been registered')) {
        throw AuthException(AppConstants.errorEmailInUse);
      }
      if (e.message.toLowerCase().contains('rate limit')) {
        throw AuthException(AppConstants.errorRateLimit);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<void> resendVerification(String email, {String? phone}) async {
    try {
      if (phone != null && phone.isNotEmpty) {
        // Resend SMS
        await _client.auth.resend(
          type: OtpType.sms,
          phone: phone,
        );
      } else {
        // Resend Email
        await _client.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: AppConstants.authRedirectUrl('/login'),
        );
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('rate limit')) {
        throw AuthException(AppConstants.errorRateLimit);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
