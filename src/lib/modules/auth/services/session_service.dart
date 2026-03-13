import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/models/user_model.dart';

class SessionService {
  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<void> saveSession(UserModel user, String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.prefKeyUserId, user.id);
    await prefs.setString(AppConstants.prefKeyUserEmail, user.email);
    await prefs.setString(
      AppConstants.prefKeyUserName,
      '${user.firstName} ${user.lastName}'.trim(),
    );
    await prefs.setBool(AppConstants.prefKeyIsLoggedIn, true);
    await prefs.setString(AppConstants.prefKeyAuthToken, token);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefKeyAuthToken);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.prefKeyUserId);
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.prefKeyUserId);
    await prefs.remove(AppConstants.prefKeyUserEmail);
    await prefs.remove(AppConstants.prefKeyUserName);
    await prefs.remove(AppConstants.prefKeyIsLoggedIn);
    await prefs.remove(AppConstants.prefKeyAuthToken);
  }
}

final sessionServiceProvider = Provider<SessionService>(
  (ref) => SessionService(),
);
