import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  // Register user
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful registration
        if (responseData['token'] != null) {
          await _saveToken(responseData['token']);
          await _saveUser(User.fromJson(responseData['user'] ?? responseData));
        }
        return {
          'success': true,
          'message': responseData['message'] ?? 'Kayıt başarılı',
          'user': responseData['user'],
          'token': responseData['token'],
        };
      } else {
        // Registration failed
        return {
          'success': false,
          'message': responseData['message'] ?? 'Kayıt başarısız',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Successful login
        if (responseData['token'] != null) {
          await _saveToken(responseData['token']);
          await _saveUser(User.fromJson(responseData['user'] ?? responseData));
          await _setLoggedIn(true);
        }
        return {
          'success': true,
          'message': responseData['message'] ?? 'Giriş başarılı',
          'user': responseData['user'],
          'token': responseData['token'],
        };
      } else {
        // Login failed
        return {
          'success': false,
          'message': responseData['message'] ?? 'Giriş başarısız',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // Get saved user
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Private methods
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
  }

  Future<void> _setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, isLoggedIn);
  }
}
