class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://takip.kiracilarim.com/api';

  // API Endpoints
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String loginEndpoint = '$baseUrl/auth/login';

  // Habit Endpoints
  static const String habitsEndpoint = '$baseUrl/habits';
  static const String habitUpdateEndpoint = '$baseUrl/habits';
  static const String habitDeleteEndpoint = '$baseUrl/habits';
  static const String habitCompleteEndpoint = '$baseUrl/habits';

  // App Colors - Modern Medical Theme
  static const int primaryColorValue = 0xFF667EEA; // Modern purple-blue
  static const int secondaryColorValue = 0xFF764BA2; // Purple gradient
  static const int accentColorValue = 0xFF10B981; // Modern green
  static const int backgroundColorValue = 0xFFF8FAFC; // Very light blue-gray
  static const int cardColorValue = 0xFFFFFFFF; // Pure white
  static const int textPrimaryValue = 0xFF1E293B; // Modern dark slate
  static const int textSecondaryValue = 0xFF64748B; // Modern gray
  static const int errorColorValue = 0xFFEF4444; // Modern red
  static const int successColorValue = 0xFF10B981; // Modern green
  static const int warningColorValue = 0xFFF59E0B; // Modern amber

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Strings
  static const String appName = 'İlaç Vakti';
  static const String welcomeMessage =
      'Sağlığınız için güvenilir takip';
  
  // OneSignal Configuration
  static const String oneSignalAppId = 'afc81817-71be-432e-a1c1-c446fa01c046';
}
