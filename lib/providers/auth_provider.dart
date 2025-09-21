import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/onesignal_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  final AuthService _authService = AuthService();
  final OneSignalService _oneSignalService = OneSignalService();

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _token = await _authService.getToken();
        _user = await _authService.getUser();
        print('🔐 Auth initialized - User: ${_user?.name}, Token: ${_token?.substring(0, 10)}...');
      } else {
        print('❌ User not logged in');
      }
    } catch (e) {
      print('💥 Error initializing auth: $e');
      debugPrint('Error initializing auth: $e');
      _isLoggedIn = false;
      _token = null;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set user
  Future<void> setUser(User user) async {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Set token
  Future<void> setToken(String token) async {
    _token = token;
    notifyListeners();
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final result = await _authService.login(loginRequest);

      if (result['success']) {
        _user = User.fromJson(result['user']);
        _token = result['token'];
        _isLoggedIn = true;
        
        // OneSignal'e kullanıcı girişini bildir
        await _oneSignalService.onUserLogin(
          _user!.id.toString(),
          email: _user!.email,
          name: _user!.name,
        );
        
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Bir hata oluştu: $e',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final result = await _authService.register(request);

      if (result['success'] && result['user'] != null && result['token'] != null) {
        _user = User.fromJson(result['user']);
        _token = result['token'];
        _isLoggedIn = true;
        
        // OneSignal'e kullanıcı girişini bildir
        await _oneSignalService.onUserLogin(
          _user!.id.toString(),
          email: _user!.email,
          name: _user!.name,
        );
        
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Bir hata oluştu: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // OneSignal'e kullanıcı çıkışını bildir
      await _oneSignalService.onUserLogout();
      
      await _authService.logout();
      _user = null;
      _token = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount(String password) async {
    try {
      final result = await _authService.deleteAccount(password);

      if (result['success']) {
        // OneSignal'e kullanıcı çıkışını bildir
        await _oneSignalService.onUserLogout();
        
        _user = null;
        _token = null;
        _isLoggedIn = false;
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Bir hata oluştu: $e',
      };
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      if (_isLoggedIn) {
        _user = await _authService.getUser();
        _token = await _authService.getToken();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }
}

