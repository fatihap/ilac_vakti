import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Hoş Geldiniz!',
      description: 'İlaç Vakti ile sağlıklı yaşamınıza düzen getirin. Artık hiçbir dozunuzu kaçırmayacaksınız!',
      icon: FontAwesomeIcons.pills,
      gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      illustration: '💊',
    ),
    OnboardingPage(
      title: 'Akıllı Hatırlatmalar',
      description: 'Kişiselleştirilmiş bildirimlerle ilaçlarınızı tam zamanında alın. Kaçan dozlar için otomatik tekrar hatırlatma!',
      icon: FontAwesomeIcons.bell,
      gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      illustration: '🔔',
    ),
    OnboardingPage(
      title: 'Sağlığınız Öncelik',
      description: 'İlaç geçmişinizi takip edin, dozlarınızı kaydedin ve sağlıklı yaşam alışkanlıkları edinin.',
      icon: FontAwesomeIcons.heartPulse,
      gradient: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      illustration: '❤️',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _pages[_currentPage].gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '💊',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    // Skip button
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Geç',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Bottom navigation
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Navigation buttons
                      Row(
                        children: [
                          // Previous button
                          if (_currentPage > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousPage,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(FontAwesomeIcons.arrowLeft, size: 14),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Geri',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Spacer(),

                          if (_currentPage > 0) const SizedBox(width: 16),

                          // Next/Finish button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _pages[_currentPage].gradient[0],
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentPage == _pages.length - 1
                                        ? 'Başlayalım!'
                                        : 'Devam',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentPage == _pages.length - 1
                                        ? FontAwesomeIcons.rocket
                                        : FontAwesomeIcons.arrowRight,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenHeight < 600;
        
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flexible spacing
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  
                  // Large illustration - responsive size
                  Container(
                    width: isSmallScreen ? 150 : 180,
                    height: isSmallScreen ? 150 : 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        page.illustration,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 60 : 70,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Icon
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      page.icon,
                      size: isSmallScreen ? 24 : 28,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 28),

                  // Title - responsive font size
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Description - responsive font size and padding
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 16,
                    ),
                    child: Text(
                      page.description,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String illustration;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.illustration,
  });
}
