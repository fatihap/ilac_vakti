import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';
import '../services/message_service.dart';
import '../services/onesignal_service.dart';
import 'login_screen.dart';
import 'add_medication_screen.dart';
import 'medication_tracking_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MedicationService _medicationService = MedicationService();
  List<Medication> _todaysMedications = [];
  List<Medication> _allMedications = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('🔄 Loading data...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('📊 Fetching all medications...');
      final allResult = await _medicationService.getMedications();
      print('📋 All result success: ${allResult['success']}');

      if (mounted) {
        final allMeds = allResult['medications'] ?? [];
        print('✅ All medications count: ${allMeds.length}');

        setState(() {
          _allMedications = allMeds;
          _todaysMedications =
              allMeds; // Şimdilik tüm ilaçları bugünkü olarak göster
          _isLoading = false;
        });

        if (allMeds.isNotEmpty) {
          print(
            '📝 Medication names: ${allMeds.map((m) => m.name).join(', ')}',
          );
        }
      }
    } catch (e) {
      print('💥 Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler yüklenirken hata oluştu: $e'),
            backgroundColor: const Color(AppConstants.errorColorValue),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _takeMedication(Medication medication) async {
    // Haptic feedback ekle
    // HapticFeedback.lightImpact();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.1),
                const Color(0xFF667EEA).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getMedicationEmoji(medication.medicationType),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${medication.name} İlacı',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'İlaç alımını onaylayın',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.questionCircle,
                        color: const Color(0xFF667EEA),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${medication.name} ilacını aldınız mı?',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (medication.dosage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.prescription,
                              size: 16,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Doz: ${medication.dosage}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.heart,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getMotivationalMessage(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FontAwesomeIcons.check, size: 16),
                const SizedBox(width: 8),
                const Text('İlaç Aldım'),
              ],
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final now = DateTime.now();
        final response = await _medicationService.markMedicationTaken(
          medication.id!,
          now.toIso8601String().split('T')[0],
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        );

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${medication.name} başarıyla alındı! 🎉',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getSuccessMessage(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
          _loadData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: const Color(AppConstants.errorColorValue),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Modern Header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF667EEA),
                        const Color(0xFF764BA2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _getGreetingEmoji(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getGreetingMessage(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${authProvider.user?.name ?? 'Kullanıcı'} 👋',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getHealthMessage(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return PopupMenuButton<String>(
                                icon: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.user,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onSelected: (value) async {
                                  if (value == 'logout') {
                                    await authProvider.logout();
                                    if (context.mounted) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } else if (value == 'onboarding') {
                                    // Onboarding'i sıfırla ve göster
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.remove('onboarding_completed');

                                    if (context.mounted) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const OnboardingScreen(),
                                        ),
                                      );
                                    }
                                  } else if (value == 'delete_account') {
                                    _showDeleteAccountDialog(authProvider);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'profile',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.user,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${authProvider.user?.name ?? ''} ${authProvider.user?.surname ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),

                                  const PopupMenuItem<String>(
                                    value: 'delete_account',
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.userXmark,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Hesap Sil',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<String>(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.signOutAlt,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Çıkış Yap',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats Row
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    'Bugünkü İlaçlar',
                                    _todaysMedications.length.toString(),
                                    FontAwesomeIcons.pills,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildStatItem(
                                    'Toplam İlaç',
                                    _allMedications.length.toString(),
                                    FontAwesomeIcons.capsules,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hızlı İşlemler',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          _buildActionCard(
                            'İlaç Ekle',
                            '💊',
                            const Color(0xFF10B981),
                            () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddMedicationScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadData();
                              }
                            },
                          ),
                          _buildActionCard(
                            'İlaç Takibi',
                            '📊',
                            const Color(0xFF3B82F6),
                            () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MedicationTrackingScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Today's Medications
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İlaçlarım',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMedicationsList(),
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

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String emoji,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsList() {
    print('🎨 Building medications list - Count: ${_allMedications.length}');

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF667EEA)),
      );
    }

    if (_allMedications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('💊', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz ilaç eklemediniz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İlk ilacınızı ekleyerek başlayın',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _allMedications.map((medication) {
        print(
          '🏥 Rendering medication: ${medication.name} (ID: ${medication.id})',
        );
        return GestureDetector(
          onTap: () => _editMedication(medication),
          onLongPress: () => _showMedicationOptions(medication),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667EEA).withOpacity(0.8),
                        const Color(0xFF764BA2).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getMedicationEmoji(medication.medicationType),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.dosage ?? medication.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.repeat,
                            size: 12,
                            color: const Color(0xFF667EEA),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            medication.frequencyDescription,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667EEA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getProgressColor(medication).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (medication.isCompletedToday == true) ...[
                            const Icon(
                              FontAwesomeIcons.check,
                              size: 12,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            _getProgressText(medication),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(medication),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _takeMedication(medication),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: medication.isCompletedToday == true
                            ? Colors.green
                            : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        medication.isCompletedToday == true
                            ? 'Tamamlandı ✓'
                            : 'İlaç Al',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _editMedication(Medication medication) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(medication: medication),
      ),
    );

    if (result == true) {
      _loadData(); // Veriyi yenile
    }
  }

  Future<void> _showMedicationOptions(Medication medication) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Medication info
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF667EEA).withOpacity(0.8),
                                const Color(0xFF764BA2).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _getMedicationEmoji(medication.medicationType),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                medication.dosage ?? medication.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.penToSquare,
                              color: Color(0xFF3B82F6),
                              size: 18,
                            ),
                          ),
                          title: const Text(
                            'İlaç Düzenle',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text('İlaç bilgilerini güncelle'),
                          onTap: () => Navigator.of(context).pop('edit'),
                        ),

                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.check,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                          ),
                          title: const Text(
                            'İlaç Al',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text('İlaç aldım olarak işaretle'),
                          onTap: () => Navigator.of(context).pop('take'),
                        ),

                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.trash,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                          ),
                          title: const Text(
                            'İlaç Sil',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text('İlacı kalıcı olarak sil'),
                          onTap: () => Navigator.of(context).pop('delete'),
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
    );

    if (result != null) {
      switch (result) {
        case 'edit':
          _editMedication(medication);
          break;
        case 'take':
          _takeMedication(medication);
          break;
        case 'delete':
          _deleteMedication(medication);
          break;
      }
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              FontAwesomeIcons.triangleExclamation,
              color: Color(0xFFEF4444),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('İlaç Sil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${medication.name} ilacını silmek istediğinizden emin misiniz?',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    FontAwesomeIcons.info,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu işlem geri alınamaz.',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _medicationService.deleteMedication(
          medication.id!,
        );

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🗑️'),
                  const SizedBox(width: 8),
                  Text('${medication.name} başarıyla silindi!'),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          _loadData(); // Verileri yenile
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: const Color(AppConstants.errorColorValue),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: const Color(AppConstants.errorColorValue),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getMedicationEmoji(String? medicationType) {
    switch (medicationType) {
      case 'tablet':
        return '💊';
      case 'capsule':
        return '💉';
      case 'syrup':
        return '🍯';
      case 'drops':
        return '💧';
      case 'injection':
        return '💉';
      case 'cream':
        return '🧴';
      case 'spray':
        return '💨';
      default:
        return '💊';
    }
  }

  Color _getProgressColor(Medication medication) {
    if (medication.isCompletedToday == true) return Colors.green;

    final percentage = medication.todayCompletionPercentage ?? 0;
    if (percentage == 0) return Colors.red;
    if (percentage < 100) return Colors.orange;
    return Colors.green;
  }

  String _getProgressText(Medication medication) {
    if (medication.isCompletedToday == true) {
      return 'Tamamlandı';
    }

    final percentage = medication.todayCompletionPercentage ?? 0;
    if (percentage == 0) {
      return 'Başlanmadı';
    } else if (percentage < 100) {
      return '${percentage.toInt()}% tamamlandı';
    } else {
      return 'Tamamlandı';
    }
  }

  String _getGreetingEmoji() {
    return MessageService.getGreetingEmoji();
  }

  String _getGreetingMessage() {
    return MessageService.getGreetingMessage();
  }

  String _getHealthMessage() {
    return MessageService.getHealthMessage();
  }

  String _getMotivationalMessage() {
    return MessageService.getDialogMotivationalMessage();
  }

  String _getSuccessMessage() {
    return MessageService.getSuccessMessage();
  }

  Future<void> _showDeleteAccountDialog(AuthProvider authProvider) async {
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool obscurePassword = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Hesap Silme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.exclamationTriangle,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'DİKKAT!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bu işlem geri alınamaz. Hesabınız ve tüm verileriniz kalıcı olarak silinecektir:',
                      style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDeleteWarningItem('• Tüm ilaç kayıtlarınız'),
                        _buildDeleteWarningItem('• Hatırlatma geçmişiniz'),
                        _buildDeleteWarningItem('• Kişisel bilgileriniz'),
                        _buildDeleteWarningItem('• Hesap ayarlarınız'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Devam etmek için şifrenizi girin:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  hintText: 'Mevcut şifrenizi girin',
                  prefixIcon: const Icon(
                    FontAwesomeIcons.lock,
                    color: Colors.red,
                    size: 18,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? FontAwesomeIcons.eyeSlash
                          : FontAwesomeIcons.eye,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (passwordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Şifre gerekli'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      try {
                        final result = await authProvider.deleteAccount(
                          passwordController.text.trim(),
                        );

                        if (result['success']) {
                          Navigator.of(context).pop(true);
                        } else {
                          setState(() {
                            isLoading = false;
                          });

                          String errorMessage =
                              result['message'] ?? 'Hesap silinemedi';

                          // Password error handling
                          if (errorMessage.toLowerCase().contains('password') &&
                              (errorMessage.toLowerCase().contains(
                                    'incorrect',
                                  ) ||
                                  errorMessage.toLowerCase().contains(
                                    'wrong',
                                  ) ||
                                  errorMessage.toLowerCase().contains(
                                    'yanlış',
                                  ))) {
                            errorMessage =
                                'Şifre yanlış. Lütfen tekrar deneyin.';
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bir hata oluştu: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.trash, size: 14),
                        SizedBox(width: 8),
                        Text(
                          'Hesabı Sil',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      // Show success message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                Icon(FontAwesomeIcons.check, color: Colors.white, size: 16),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hesabınız başarıyla silindi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Tüm verileriniz kalıcı olarak silindi',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildDeleteWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      ),
    );
  }

  Future<void> _testOneSignalNotification() async {
    try {
      final oneSignalService = OneSignalService();

      // OneSignal durumunu kontrol et
      final userId = await oneSignalService.getUserId();
      final hasPermission = await oneSignalService.hasNotificationPermission();

      print('🔔 OneSignal Test - User ID: $userId');
      print('🔔 OneSignal Test - Has Permission: $hasPermission');

      if (!hasPermission) {
        await oneSignalService.requestNotificationPermission();
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      // Test tag gönder
      await oneSignalService.sendTags({
        'test_notification': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OneSignal Test Bilgileri:'),
              Text('User ID: ${userId ?? "null"}'),
              Text('Permission: $hasPermission'),
              Text('Test tag gönderildi'),
            ],
          ),
          backgroundColor: const Color(0xFF667EEA),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OneSignal Test Hatası: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
