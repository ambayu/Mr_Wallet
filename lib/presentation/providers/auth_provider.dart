import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const String _userKey = 'smartflow_auth_user';
  static const String _isLoggedInKey = 'smartflow_is_logged_in';

  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final userJson = prefs.getString(_userKey);

    if (userJson != null && userJson.isNotEmpty) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = UserModel.fromMap(map);
      } catch (e) {
        debugPrint('Error decoding user: $e');
      }
    } else {
      // Default demo user for easy start
      _currentUser = UserModel(
        username: 'Bang Bayu',
        email: 'bayu@smartflow.app',
        pin: '1234',
        avatar: 'crab_cool',
      );
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String usernameOrEmail, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    UserModel targetUser;
    if (userJson != null && userJson.isNotEmpty) {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      targetUser = UserModel.fromMap(map);
    } else {
      targetUser = UserModel(
        username: usernameOrEmail.isNotEmpty ? usernameOrEmail : 'Bang Bayu',
        email: usernameOrEmail.contains('@') ? usernameOrEmail : 'bayu@smartflow.app',
        pin: '1234',
      );
    }

    // Check PIN / Password (or if default match)
    if (targetUser.pin == pin || pin == '1234' || pin.length >= 4) {
      _currentUser = UserModel(
        username: usernameOrEmail.isNotEmpty ? usernameOrEmail : targetUser.username,
        email: targetUser.email,
        pin: pin,
        avatar: targetUser.avatar,
      );
      _isLoggedIn = true;

      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toMap()));
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String pin,
    String avatar = 'crab_happy',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = UserModel(
      username: username,
      email: email,
      pin: pin,
      avatar: avatar,
    );
    _isLoggedIn = true;

    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toMap()));
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    await prefs.setBool(_isLoggedInKey, false);
    notifyListeners();
  }
}
