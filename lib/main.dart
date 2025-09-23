import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/onesignal_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // OneSignal'i başlat
  await _initializeOneSignal();

  runApp(const MyApp());
}

Future<void> _initializeOneSignal() async {
  try {
    // OneSignal servisini başlat
    final oneSignalService = OneSignalService();
    await oneSignalService.initialize();

    // Kullanıcı ID'sini al
    final deviceState = await OneSignal.User.getOnesignalId();
    print('📱 OneSignal Device ID: $deviceState');

    // Bildirim tıklama olaylarını dinle
    OneSignal.Notifications.addClickListener((event) {
      print('🔔 Notification opened: ${event.notification}');

      // Burada bildirime tıklandığında yapılacak işlemler
      // Örneğin: belirli bir sayfaya yönlendirme
    });

    // Bildirim alındığında çalışır
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
        '🔔 Notification received in foreground: ${event.notification.body}',
      );

      // Bildirimi göster
      event.preventDefault();
      event.notification.display();
    });

    print('✅ OneSignal initialized successfully');
  } catch (e) {
    print('❌ OneSignal initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Ubuntu font ailesini kullan
          textTheme: GoogleFonts.ubuntuTextTheme(),
          primarySwatch:
              MaterialColor(AppConstants.primaryColorValue, const <int, Color>{
                50: Color(0xFFF0F4FF),
                100: Color(0xFFE0E7FF),
                200: Color(0xFFC7D2FE),
                300: Color(0xFFA5B4FC),
                400: Color(0xFF8B93F8),
                500: Color(AppConstants.primaryColorValue),
                600: Color(0xFF5B64E8),
                700: Color(0xFF4F46E5),
                800: Color(0xFF4338CA),
                900: Color(0xFF3730A3),
              }),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppConstants.primaryColorValue),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(
            AppConstants.backgroundColorValue,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Color(AppConstants.textPrimaryValue),
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColorValue),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: const Color(
                AppConstants.primaryColorValue,
              ).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(AppConstants.primaryColorValue),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(AppConstants.primaryColorValue),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            shadowColor: Colors.grey.withOpacity(0.1),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isFirstLaunch;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      _isFirstLaunch = !onboardingCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Onboarding kontrolü yapılıyor
    if (_isFirstLaunch == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 80,
                color: Color(AppConstants.primaryColorValue),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Color(AppConstants.primaryColorValue),
              ),
              SizedBox(height: 20),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.primaryColorValue),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // İlk kez açılıyorsa onboarding göster
    if (_isFirstLaunch!) {
      return const OnboardingScreen();
    }

    // Onboarding tamamlandıysa normal auth kontrolü yap
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 80,
                    color: Color(AppConstants.primaryColorValue),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    color: Color(AppConstants.primaryColorValue),
                  ),
                  SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.primaryColorValue),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (authProvider.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
