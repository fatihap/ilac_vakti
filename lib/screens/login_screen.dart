import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/onesignal_service.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final oneSignalService = OneSignalService();

      // OneSignal Subscription ID'sini al (bildirimler için)
      final oneSignalId = await oneSignalService.getSubscriptionId();
      print('📱 OneSignal Subscription ID: ${oneSignalId ?? "null"}');

      final loginRequest = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        onesignalId: oneSignalId,
      );

      final result = await authService.login(loginRequest);

      if (result['success']) {
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          await authProvider.setUser(User.fromJson(result['user']));
          await authProvider.setToken(result['token']);

          // OneSignal'e kullanıcı giriş bilgilerini gönder
          final user = User.fromJson(result['user']);
          await oneSignalService.onUserLogin(
            user.id.toString(),
            email: user.email,
            name: user.name,
          );

          print(
            '✅ Login successful - User: ${result['user']['name']}, Token: ${result['token']?.substring(0, 20)}...',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: const Color(AppConstants.successColorValue),
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        if (mounted) {
          String errorMessage = result['message'] ?? 'Giriş işlemi başarısız';

          // E-posta bulunamadı durumu için özel mesaj
          if (errorMessage.toLowerCase().contains('email') &&
              (errorMessage.toLowerCase().contains('not found') ||
                  errorMessage.toLowerCase().contains('bulunamadı') ||
                  errorMessage.toLowerCase().contains('does not exist'))) {
            errorMessage =
                'Bu e-posta adresi kayıtlı değil. Hesap oluşturmayı deneyin.';
          }
          // Şifre yanlış durumu için özel mesaj
          else if (errorMessage.toLowerCase().contains('password') &&
              (errorMessage.toLowerCase().contains('incorrect') ||
                  errorMessage.toLowerCase().contains('wrong') ||
                  errorMessage.toLowerCase().contains('yanlış'))) {
            errorMessage = 'Şifre yanlış. Lütfen tekrar deneyin.';
          }
          // Genel kimlik doğrulama hatası
          else if (errorMessage.toLowerCase().contains('credentials') ||
              errorMessage.toLowerCase().contains('unauthorized')) {
            errorMessage = 'E-posta veya şifre hatalı. Lütfen kontrol edin.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: const Color(AppConstants.errorColorValue),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: const Color(AppConstants.errorColorValue),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(AppConstants.backgroundColorValue),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Logo and Welcome Section
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),

                              // App Logo
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        AppConstants.primaryColorValue,
                                      ),
                                      const Color(
                                        AppConstants.secondaryColorValue,
                                      ),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        AppConstants.primaryColorValue,
                                      ).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/app_logo.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        FontAwesomeIcons.heartPulse,
                                        color: Colors.white,
                                        size: 40,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // App Title
                              Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(
                                    AppConstants.textPrimaryValue,
                                  ),
                                  letterSpacing: 0.5,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Sağlığınız için güvenilir takip',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(
                                    AppConstants.textSecondaryValue,
                                  ),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Login Form Section
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Welcome Text
                              Text(
                                'Hoş Geldiniz',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(
                                    AppConstants.textPrimaryValue,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Hesabınıza giriş yapın',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(
                                    AppConstants.textSecondaryValue,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Login Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Email Field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: 'E-posta',
                                        hintText: 'ornek@email.com',
                                        prefixIcon: Icon(
                                          FontAwesomeIcons.envelope,
                                          color: const Color(
                                            AppConstants.primaryColorValue,
                                          ),
                                          size: 20,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(
                                              AppConstants.primaryColorValue,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'E-posta adresi gerekli';
                                        }
                                        if (!EmailValidator.validate(value)) {
                                          return 'Geçerli bir e-posta adresi girin';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Password Field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: 'Şifre',
                                        hintText: 'Şifrenizi girin',
                                        prefixIcon: Icon(
                                          FontAwesomeIcons.lock,
                                          color: const Color(
                                            AppConstants.primaryColorValue,
                                          ),
                                          size: 20,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? FontAwesomeIcons.eyeSlash
                                                : FontAwesomeIcons.eye,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(
                                              AppConstants.primaryColorValue,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Şifre gerekli';
                                        }
                                        if (value.length < 6) {
                                          return 'Şifre en az 6 karakter olmalı';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // Login Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            AppConstants.primaryColorValue,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shadowColor: const Color(
                                            AppConstants.primaryColorValue,
                                          ).withOpacity(0.3),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SpinKitThreeBounce(
                                                color: Colors.white,
                                                size: 20,
                                              )
                                            : const Text(
                                                'Giriş Yap',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(AppConstants.primaryColorValue),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Yeni Hesap Oluştur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  AppConstants.primaryColorValue,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
