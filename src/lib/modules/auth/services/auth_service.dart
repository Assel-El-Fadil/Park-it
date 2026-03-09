import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/constants/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('already been registered')) {
        throw AuthException(AppConstants.errorEmailInUse);
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
    } on AuthException catch (e) {
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _client.auth.updateUser(UserAttributes(data: data));
    } on AuthException catch (e) {
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

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('weak')) {
        throw AuthException(AppConstants.errorWeakPassword);
      }
      throw AuthException(AppConstants.errorGeneric);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(AppConstants.errorGeneric);
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
