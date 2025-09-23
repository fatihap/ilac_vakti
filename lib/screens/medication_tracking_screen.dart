import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';
import '../services/message_service.dart';
import '../constants/app_constants.dart';
import 'add_medication_screen.dart';

class MedicationTrackingScreen extends StatefulWidget {
  const MedicationTrackingScreen({super.key});

  @override
  State<MedicationTrackingScreen> createState() =>
      _MedicationTrackingScreenState();
}

class _MedicationTrackingScreenState extends State<MedicationTrackingScreen> {
  List<Medication> _allMedications = []; // Tüm ilaçlar
  List<Medication> _medications = []; // Filtrelenmiş ilaçlar
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  Map<int, Map<String, bool>> _medicationTracking =
      {}; // medicationId -> {time: taken}
  Set<String> _savingMedications = {}; // Kaydedilmekte olan ilaçlar

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final medicationService = MedicationService();
      final selectedDateStr = _selectedDate.toIso8601String().split('T')[0];
      
      // Önce belirli tarih için ilaç durumlarını getir
      final dateResult = await medicationService.getMedicationsForDate(selectedDateStr);
      
      if (dateResult['success']) {
        final dateMedications = dateResult['medications'] ?? [];
        setState(() {
          _medications = dateMedications;
        });
        
        // Eğer belirli tarih için veri yoksa, genel ilaç listesini getir
        if (dateMedications.isEmpty) {
          final generalResult = await medicationService.getMedications();
          if (generalResult['success']) {
            final allMedications = generalResult['medications'] ?? [];
            setState(() {
              _allMedications = allMedications;
            });
            _filterMedicationsForDate();
          }
        } else {
          // Belirli tarih için veri varsa, tracking verilerini de getir
          await _loadTrackingDataForDate(selectedDateStr);
        }
      } else {
        // Belirli tarih için veri yoksa, genel ilaç listesini getir
        final generalResult = await medicationService.getMedications();
        if (generalResult['success']) {
          final allMedications = generalResult['medications'] ?? [];
          setState(() {
            _allMedications = allMedications;
          });
          _filterMedicationsForDate();
        }
      }
    } catch (e) {
      print('Error loading medications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTrackingDataForDate(String date) async {
    try {
      final medicationService = MedicationService();
      final trackingResult = await medicationService.getMedicationTrackingForDate(date);
      
      if (trackingResult['success']) {
        final trackingData = trackingResult['tracking'] ?? {};
        _updateTrackingDataFromAPI(trackingData);
      }
    } catch (e) {
      print('Error loading tracking data: $e');
    }
  }

  void _updateTrackingDataFromAPI(Map<String, dynamic> trackingData) {
    _medicationTracking = {};
    
    for (final medication in _medications) {
      if (medication.id != null) {
        _medicationTracking[medication.id!] = {};
        
        if (medication.allReminderTimes != null) {
          for (final time in medication.allReminderTimes!) {
            // API'den gelen tracking verilerine göre durumu ayarla
            final key = '${medication.id}_$time';
            _medicationTracking[medication.id!]![time] = trackingData[key] ?? false;
          }
        }
      }
    }
  }

  void _initializeTrackingData() {
    _medicationTracking = {};
    for (final medication in _medications) {
      if (medication.id != null) {
        _medicationTracking[medication.id!] = {};
        if (medication.allReminderTimes != null) {
          // API'den gelen completion percentage'e göre hangi saatlerin alındığını hesapla
          final totalTimes = medication.allReminderTimes!.length;
          final completedCount =
              ((medication.todayCompletionPercentage ?? 0) / 100 * totalTimes)
                  .round();

          for (int i = 0; i < medication.allReminderTimes!.length; i++) {
            final time = medication.allReminderTimes![i];
            // İlk N saat alınmış olarak işaretle (N = completedCount)
            _medicationTracking[medication.id!]![time] = i < completedCount;
          }
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMedications(); // Tarih değiştiğinde yeni verileri yükle
    }
  }

  void _navigateDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadMedications(); // Tarih değiştiğinde yeni verileri yükle
  }

  void _filterMedicationsForDate() {
    final filteredMedications = _allMedications.where((medication) {
      final startDate = DateTime.parse(medication.startDate);
      final endDate = medication.endDate != null
          ? DateTime.parse(medication.endDate!)
          : null;

      // İlaç bu tarihte aktif mi kontrol et
      final isActiveOnDate =
          _selectedDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          (endDate == null ||
              _selectedDate.isBefore(endDate.add(const Duration(days: 1))));

      return isActiveOnDate;
    }).toList();

    setState(() {
      _medications = filteredMedications;
      _initializeTrackingData();
    });
  }

  Future<void> _toggleMedicationTaken(int medicationId, String time) async {
    final currentStatus = _medicationTracking[medicationId]![time] ?? false;
    final newStatus = !currentStatus;
    final savingKey = '${medicationId}_$time';

    // Loading state'i başlat
    setState(() {
      _medicationTracking[medicationId]![time] = newStatus;
      if (newStatus) {
        _savingMedications.add(savingKey);
      }
    });

    // API'ye kaydet
    if (newStatus) {
      try {
        final medicationService = MedicationService();
        final result = await medicationService.markMedicationTaken(
          medicationId,
          _selectedDate.toIso8601String().split(
            'T',
          )[0], // YYYY-MM-DD formatında tarih
          time,
        );

        if (result['success']) {
          // Başarılı kayıt - motivasyonel feedback göster
          _showMotivationalFeedback(true);

          // Sadece tracking verilerini yeniden yükle (tüm ilaç listesini değil)
          await _loadTrackingDataForDate(_selectedDate.toIso8601String().split('T')[0]);

          print('✅ Medication marked as taken: $medicationId at $time');

          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'İlaç başarıyla kaydedildi! 🎉',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // API hatası - eski duruma döndür
          setState(() {
            _medicationTracking[medicationId]![time] = currentStatus;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'İlaç kaydedilemedi',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Network hatası - eski duruma döndür
        setState(() {
          _medicationTracking[medicationId]![time] = currentStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bağlantı hatası: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        print('❌ Error marking medication as taken: $e');
      } finally {
        // Loading state'i bitir
        setState(() {
          _savingMedications.remove(savingKey);
        });
      }
    } else {
      // İlaç alınmadı olarak işaretlendi - sadece local güncelleme
      // (Backend'de "unmark" API'si yoksa sadece UI'da göster)
      print('ℹ️ Medication unmarked locally: $medicationId at $time');
    }
  }

  void _showMotivationalFeedback(bool isPositive) {
    final message = isPositive
        ? MessageService.getPositiveFeedbackMessage()
        : MessageService.getNegativeFeedbackMessage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isPositive ? FontAwesomeIcons.check : FontAwesomeIcons.clock,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isPositive
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMedicationAction(String action, Medication medication) async {
    switch (action) {
      case 'edit':
        await _editMedication(medication);
        break;
      case 'delete':
        await _deleteMedication(medication);
        break;
    }
  }

  Future<void> _editMedication(Medication medication) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(medication: medication),
      ),
    );

    // İlaç düzenlendikten sonra listeyi yenile
    _loadMedications();
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FontAwesomeIcons.trash,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'İlaç Sil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${medication.name} ilacını silmek istediğinizden emin misiniz?',
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu işlem geri alınamaz!',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
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
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sil',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && medication.id != null) {
      try {
        final medicationService = MedicationService();
        final result = await medicationService.deleteMedication(medication.id!);

        if (result['success']) {
          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${medication.name} başarıyla silindi',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // Listeyi yenile
          _loadMedications();
        } else {
          // Hata mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'İlaç silinirken bir hata oluştu',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'İlaç silinirken bir hata oluştu: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  double _getMedicationProgress(int medicationId) {
    final tracking = _medicationTracking[medicationId];
    if (tracking == null || tracking.isEmpty) return 0.0;

    final takenCount = tracking.values.where((taken) => taken).length;
    return takenCount / tracking.length;
  }

  int _getCompletedCount(int medicationId) {
    final tracking = _medicationTracking[medicationId];
    if (tracking == null) return 0;

    return tracking.values.where((taken) => taken).length;
  }

  int _getTotalCount(int medicationId) {
    final tracking = _medicationTracking[medicationId];
    if (tracking == null) return 0;

    return tracking.length;
  }

  Color _getProgressColor(double progress) {
    if (progress == 0.0) return Colors.red;
    if (progress < 1.0) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern Header
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF667EEA),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                FontAwesomeIcons.calendarCheck,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'İlaç Takip Merkezi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Günlük ilaç alımınızı takip edin',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Enhanced Date Selector
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous day button
                              GestureDetector(
                                onTap: () => _navigateDate(-1),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.chevronLeft,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),

                              // Date display
                              GestureDetector(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.calendar,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Next day button
                              GestureDetector(
                                onTap: () => _navigateDate(1),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.chevronRight,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? Container(
                    height: 400,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF667EEA),
                      ),
                    ),
                  )
                : _medications.isEmpty
                ? Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
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
                                Icon(
                                  FontAwesomeIcons.calendarXmark,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bu tarihte ilaç bulunmuyor',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_formatDate(_selectedDate)} tarihinde aktif ilaç yok',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF667EEA,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _getEmptyStateMessage(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: const Color(0xFF667EEA),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Başka bir tarih seçmeyi deneyin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF667EEA),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Motivasyonel mesaj kartı
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF667EEA).withOpacity(0.1),
                                const Color(0xFF764BA2).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF667EEA).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF667EEA,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.heart,
                                      color: Color(0xFF667EEA),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isAllMedicationsCompleted()
                                              ? 'Tebrikler! 🎉'
                                              : 'Sağlık Motivasyonu 💪',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _isAllMedicationsCompleted()
                                              ? _getCompletionMessage()
                                              : _getMotivationalMessage(),
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
                            ],
                          ),
                        ),

                        // İlaç kartları
                        ..._medications.map((medication) {
                          return _buildMedicationTrackingCard(medication);
                        }).toList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationTrackingCard(Medication medication) {
    if (medication.id == null) return const SizedBox.shrink();

    final progress = _getMedicationProgress(medication.id!);
    final progressColor = _getProgressColor(progress);
    final takenCount = _getCompletedCount(medication.id!);
    final totalCount = _getTotalCount(medication.id!);
    final isCompletedToday = medication.isCompletedToday ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                    child: Icon(
                      _getMedicationIcon(medication.medicationType),
                      size: 24,
                      color: Colors.white,
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
                          fontSize: 20,
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
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isCompletedToday
                            ? Colors.green.withOpacity(0.1)
                            : progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCompletedToday) ...[
                            const Icon(
                              FontAwesomeIcons.check,
                              size: 12,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '$takenCount/$totalCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCompletedToday
                                  ? Colors.green
                                  : progressColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // İlaç yönetim menüsü
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMedicationAction(value, medication),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.penToSquare,
                                  color: Color(0xFF3B82F6),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'İlaç Düzenle',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.trash,
                                  color: Color(0xFFEF4444),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'İlaç Sil',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.ellipsisVertical,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompletedToday ? Colors.green : progressColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Time Slots
            if (medication.allReminderTimes != null &&
                medication.allReminderTimes!.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: medication.allReminderTimes!.map((time) {
                  final isTaken =
                      _medicationTracking[medication.id!]?[time] ?? false;
                  final savingKey = '${medication.id!}_$time';
                  final isSaving = _savingMedications.contains(savingKey);

                  return GestureDetector(
                    onTap: isSaving
                        ? null
                        : () async => await _toggleMedicationTaken(
                            medication.id!,
                            time,
                          ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isTaken ? progressColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isTaken ? progressColor : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSaving)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isTaken
                                    ? Colors.white
                                    : const Color(0xFF667EEA),
                              ),
                            )
                          else
                            Icon(
                              isTaken
                                  ? FontAwesomeIcons.check
                                  : FontAwesomeIcons.clock,
                              size: 16,
                              color: isTaken
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isTaken
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getMedicationIcon(String? medicationType) {
    switch (medicationType) {
      case 'tablet':
        return FontAwesomeIcons.pills;
      case 'capsule':
        return FontAwesomeIcons.syringe;
      case 'syrup':
        return FontAwesomeIcons.bottleDroplet;
      case 'drops':
        return FontAwesomeIcons.droplet;
      case 'injection':
        return FontAwesomeIcons.syringe;
      case 'cream':
        return FontAwesomeIcons.soap;
      case 'spray':
        return FontAwesomeIcons.sprayCan;
      default:
        return FontAwesomeIcons.pills;
    }
  }

  String _getMotivationalMessage() {
    return MessageService.getMotivationalMessage();
  }

  String _getCompletionMessage() {
    return MessageService.getCompletionMessage();
  }

  String _getEmptyStateMessage() {
    return MessageService.getEmptyStateMessage();
  }

  bool _isAllMedicationsCompleted() {
    if (_medications.isEmpty) return false;

    return _medications.every((medication) {
      if (medication.id == null) return false;
      final progress = _getMedicationProgress(medication.id!);
      return progress == 1.0;
    });
  }
}
