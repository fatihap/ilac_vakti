import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_constants.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  FrequencyType _selectedFrequency = FrequencyType.daily;
  MedicationType? _selectedMedicationType;
  List<TimeOfDay> _reminderTimes = [];
  int _frequencyInterval = 1;
  int _targetCount = 1;
  List<int> _selectedDays = [];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;

  // New fields for updated API structure
  int _dailyNotificationCount = 1;
  bool _snoozeEnabled = true;
  int _snoozeDurationMinutes = 15;
  int _maxSnoozes = 3;

  final List<String> _weekDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  // Predefined time slots for easy selection
  final List<TimeOfDay> _predefinedTimes = [
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 13, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
    const TimeOfDay(hour: 17, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
    const TimeOfDay(hour: 19, minute: 0),
    const TimeOfDay(hour: 20, minute: 0),
    const TimeOfDay(hour: 21, minute: 0),
    const TimeOfDay(hour: 22, minute: 0),
    const TimeOfDay(hour: 23, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _loadMedicationData();
    }
  }

  void _loadMedicationData() {
    final medication = widget.medication!;
    _nameController.text = medication.name;
    _descriptionController.text = medication.description;
    _dosageController.text = medication.dosage ?? '';
    _instructionsController.text = medication.instructions ?? '';

    // Load reminder times from either reminderTimes list or single reminderTime
    _reminderTimes = [];

    // Debug: Print all medication data
    print('🔍 Full medication data: ${medication.toJson()}');
    print('🔍 reminderTimes: ${medication.reminderTimes}');
    print('🔍 reminderTime: ${medication.reminderTime}');
    print('🔍 allReminderTimes: ${medication.allReminderTimes}');
    print('🔍 targetCount: ${medication.targetCount}');

    if (medication.reminderTimes != null &&
        medication.reminderTimes!.isNotEmpty) {
      // Load from reminderTimes list
      print(
        '📅 Loading reminder times from reminderTimes: ${medication.reminderTimes}',
      );
      for (final timeString in medication.reminderTimes!) {
        final timeParts = timeString.split(':');
        if (timeParts.length == 2) {
          _reminderTimes.add(
            TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            ),
          );
        }
      }
    } else if (medication.allReminderTimes != null &&
        medication.allReminderTimes!.isNotEmpty) {
      // Load from allReminderTimes list (alternative field)
      print(
        '📅 Loading reminder times from allReminderTimes: ${medication.allReminderTimes}',
      );
      for (final timeString in medication.allReminderTimes!) {
        final timeParts = timeString.split(':');
        if (timeParts.length == 2) {
          _reminderTimes.add(
            TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            ),
          );
        }
      }
    } else if (medication.reminderTime != null) {
      // Load from single reminderTime
      print(
        '📅 Loading reminder time from reminderTime: ${medication.reminderTime}',
      );
      final timeParts = medication.reminderTime!.split(':');
      if (timeParts.length == 2) {
        _reminderTimes = [
          TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          ),
        ];
      }
    } else {
      print('⚠️ No reminder times found in medication data');
    }

    print(
      '📅 Loaded ${_reminderTimes.length} reminder times: ${_reminderTimes.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').join(', ')}',
    );

    // Set daily notification count to match the loaded reminder times
    // This ensures the UI shows the correct number of selected times
    if (_reminderTimes.isNotEmpty) {
      _dailyNotificationCount = _reminderTimes.length;
    } else {
      // Fallback to target count if no reminder times are loaded
      _dailyNotificationCount = medication.targetCount;
    }

    print('📅 Daily notification count set to: $_dailyNotificationCount');

    _startDate = DateTime.parse(medication.startDate);
    if (medication.endDate != null) {
      _endDate = DateTime.parse(medication.endDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _addReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTimes.add(picked);
        _reminderTimes.sort((a, b) => a.hour.compareTo(b.hour));
      });
    }
  }

  void _removeReminderTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  Future<void> _selectStartDate() async {
    // Düzenleme modunda geçmiş tarihleri de seçebilmek için firstDate'i ayarla
    final firstDate = widget.medication != null
        ? DateTime.now().subtract(
            const Duration(days: 365),
          ) // Düzenleme modunda 1 yıl öncesine kadar
        : DateTime.now(); // Yeni ilaç eklerken sadece bugün ve sonrası

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      if (_selectedDays.contains(dayIndex + 1)) {
        _selectedDays.remove(dayIndex + 1);
      } else {
        _selectedDays.add(dayIndex + 1);
      }
    });
  }

  void _toggleTimeSelection(TimeOfDay time) {
    setState(() {
      final existingIndex = _reminderTimes.indexWhere(
        (selectedTime) =>
            selectedTime.hour == time.hour &&
            selectedTime.minute == time.minute,
      );

      if (existingIndex != -1) {
        // Remove if already selected
        _reminderTimes.removeAt(existingIndex);
      } else if (_reminderTimes.length < _dailyNotificationCount) {
        // Add if under limit
        _reminderTimes.add(time);
        _reminderTimes.sort((a, b) => a.hour.compareTo(b.hour));
      }
    });
  }

  void _updateNotificationCountFromDose(String dose) {
    if (dose.isEmpty) return;

    // Doz metninden sayı çıkarmaya çalış
    final RegExp numberRegex = RegExp(r'(\d+)');
    final match = numberRegex.firstMatch(dose.toLowerCase());

    if (match != null) {
      final number = int.tryParse(match.group(1)!);
      if (number != null && number > 0 && number <= 10) {
        // Eğer dozda bir sayı varsa ve makul bir aralıktaysa, bildirim sayısını güncelle
        setState(() {
          _dailyNotificationCount = number;
          // Mevcut saatleri yeni sayıya göre ayarla
          if (_reminderTimes.length > _dailyNotificationCount) {
            _reminderTimes = _reminderTimes
                .take(_dailyNotificationCount)
                .toList();
          }
        });
      }
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that all required times are selected
    if (_reminderTimes.length != _dailyNotificationCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_dailyNotificationCount saat seçmelisiniz. ${_dailyNotificationCount - _reminderTimes.length} saat daha seçin.',
          ),
          backgroundColor: const Color(AppConstants.errorColorValue),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final medicationService = MedicationService();

      // Prepare reminder times in HH:MM format
      final reminderTimeStrings = _reminderTimes
          .map(
            (time) =>
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          )
          .toList();

      // Create the new API request structure
      final requestData = {
        "name": _nameController.text.trim(),
        "description": _descriptionController.text.trim().isEmpty
            ? _nameController.text.trim()
            : _descriptionController.text.trim(),
        "frequency_type": "daily", // Always daily for the new structure
        "frequency_interval": 1,
        "target_count": _dailyNotificationCount,
        "reminder_schedule": {
          "type": "fixed_times",
          "times": reminderTimeStrings,
        },
        "snooze_settings": {
          "enabled": _snoozeEnabled,
          "duration_minutes": _snoozeDurationMinutes,
          "max_snoozes": _maxSnoozes,
        },
        "start_date": _startDate.toIso8601String().split('T')[0],
        "end_date": _endDate?.toIso8601String().split('T')[0],
        "dosage": _dosageController.text.trim().isEmpty
            ? null
            : _dosageController.text.trim(),
        "instructions": _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
      };

      print('📤 Sending medication request: $requestData');

      final result = widget.medication == null
          ? await medicationService.addMedication(requestData)
          : await medicationService.updateMedication(
              widget.medication!.id!,
              requestData,
            );

      if (result['success']) {
        // Bildirim ayarla
        try {
          // İlaç ID'sini result'tan al
          final medicationId = result['data']?['id'] ?? widget.medication?.id;
          if (medicationId != null) {
            final medication = Medication(
              id: medicationId is String
                  ? int.tryParse(medicationId)
                  : medicationId,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              dosage: _dosageController.text.trim().isEmpty
                  ? null
                  : _dosageController.text.trim(),
              reminderTime: reminderTimeStrings.isNotEmpty
                  ? reminderTimeStrings.first
                  : null,
              frequencyType: "daily",
              frequencyInterval: 1,
              targetCount: _dailyNotificationCount,
              medicationType: _selectedMedicationType?.name,
              startDate: _startDate.toIso8601String().split('T')[0],
              reminderTimes: reminderTimeStrings,
            );

            print('✅ Notification scheduled for ${medication.name}');
          }
        } catch (e) {
          print('⚠️ Error scheduling notification: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🎉'),
                  const SizedBox(width: 8),
                  Text(result['message'] ?? 'İlaç başarıyla kaydedildi'),
                ],
              ),
              backgroundColor: const Color(AppConstants.successColorValue),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          String errorMessage = result['message'] ?? 'Bir hata oluştu';

          if (result['errors'] != null) {
            final errors = result['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];

            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              } else {
                errorMessages.add(value.toString());
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
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
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          FontAwesomeIcons.arrowLeft,
                          color: Colors.white,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.medication == null
                            ? 'Yeni İlaç'
                            : 'İlaç Düzenle',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text('💊', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.medication == null
                        ? 'İlaç bilgilerini girerek hatırlatıcı oluşturun'
                        : 'İlaç bilgilerini güncelleyin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // İlaç Adı
                      _buildTextField(
                        controller: _nameController,
                        label: 'İlaç Adı',
                        hint: 'Örn: Aspirin, Parol',
                        icon: FontAwesomeIcons.pills,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'İlaç adı gerekli';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Açıklama
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Açıklama (Opsiyonel)',
                        hint: 'İlaç hakkında kısa bilgi',
                        icon: FontAwesomeIcons.fileText,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 20),

                      // Doz
                      _buildTextField(
                        controller: _dosageController,
                        label: 'Doz',
                        hint: '1 tablet, 2 tablet, 5ml, 500mg',
                        icon: FontAwesomeIcons.prescription,
                        onChanged: (value) =>
                            _updateNotificationCountFromDose(value),
                      ),

                      const SizedBox(height: 20),

                      // Günlük Bildirim Sayısı
                      _buildDailyNotificationCount(),

                      const SizedBox(height: 20),

                      // Hatırlatma Saatleri
                      _buildReminderTimes(),

                      const SizedBox(height: 20),

                      // Snooze Ayarları
                      _buildSnoozeSettings(),

                      const SizedBox(height: 20),

                      // Başlangıç Tarihi
                      _buildDateSelector(
                        'Başlangıç Tarihi',
                        _startDate,
                        _selectStartDate,
                        FontAwesomeIcons.calendarPlus,
                      ),

                      const SizedBox(height: 20),

                      // Bitiş Tarihi
                      _buildDateSelector(
                        'Bitiş Tarihi (Opsiyonel)',
                        _endDate,
                        _selectEndDate,
                        FontAwesomeIcons.calendarMinus,
                      ),

                      const SizedBox(height: 20),

                      // Kaydet Butonu
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF667EEA),
                              const Color(0xFF764BA2),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveMedication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.medication == null
                                          ? FontAwesomeIcons.plus
                                          : FontAwesomeIcons.penToSquare,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.medication == null
                                          ? 'İlaç Ekle'
                                          : 'Güncelle',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF667EEA), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF667EEA), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemBuilder(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFrequencyDetails() {
    switch (_selectedFrequency) {
      case FrequencyType.hourly:
        return _buildNumberSelector(
          'Kaç saatte bir?',
          _frequencyInterval,
          1,
          24,
          (value) => setState(() => _frequencyInterval = value),
        );
      case FrequencyType.daily:
        return _buildNumberSelector(
          'Günde kaç kez?',
          _targetCount,
          1,
          10,
          (value) => setState(() => _targetCount = value),
        );
      case FrequencyType.weekly:
        return _buildWeeklyDaySelector();
      case FrequencyType.monthly:
        return _buildNumberSelector(
          'Ayda kaç kez?',
          _targetCount,
          1,
          31,
          (value) => setState(() => _targetCount = value),
        );
      case FrequencyType.yearly:
        return _buildNumberSelector(
          'Yılda kaç kez?',
          _targetCount,
          1,
          12,
          (value) => setState(() => _targetCount = value),
        );
    }
  }

  Widget _buildNumberSelector(
    String label,
    int value,
    int min,
    int max,
    void Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(FontAwesomeIcons.minus),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                  foregroundColor: const Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(FontAwesomeIcons.plus),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                  foregroundColor: const Color(0xFF667EEA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDaySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hangi günler?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isSelected = _selectedDays.contains(index + 1);

              return FilterChip(
                label: Text(
                  day,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _toggleDay(index),
                selectedColor: const Color(0xFF667EEA),
                backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyNotificationCount() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.bell,
                color: Color(0xFF667EEA),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Günlük Bildirim Sayısı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Günde kaç kez bildirim almak istiyorsunuz?\n(Doz alanına sayı girdiğinizde otomatik ayarlanır)',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _dailyNotificationCount > 1
                    ? () => setState(() {
                        _dailyNotificationCount--;
                        // Seçilen saatleri yeni sayıya göre ayarla
                        if (_reminderTimes.length > _dailyNotificationCount) {
                          _reminderTimes = _reminderTimes
                              .take(_dailyNotificationCount)
                              .toList();
                        }
                      })
                    : null,
                icon: const Icon(FontAwesomeIcons.minus),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                  foregroundColor: const Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _dailyNotificationCount.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: _dailyNotificationCount < 10
                    ? () => setState(() {
                        _dailyNotificationCount++;
                        // Bildirim sayısı artırıldığında herhangi bir saat sıfırlamaya gerek yok
                      })
                    : null,
                icon: const Icon(FontAwesomeIcons.plus),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                  foregroundColor: const Color(0xFF667EEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_dailyNotificationCount kez bildirim alacaksınız',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.clock,
                color: Color(0xFF667EEA),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hatırlatma Saatleri (${_reminderTimes.length}/${_dailyNotificationCount})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'İlaç alım saatlerini seçin:',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (_reminderTimes.length < _dailyNotificationCount)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.shade200,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.exclamationTriangle,
                    color: Colors.orange.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_dailyNotificationCount saat seçmelisiniz. ${_dailyNotificationCount - _reminderTimes.length} saat daha seçin.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_reminderTimes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade200,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.checkCircle,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tüm saatler seçildi!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Time selection grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: _predefinedTimes.length,
            itemBuilder: (context, index) {
              final time = _predefinedTimes[index];
              final isSelected = _reminderTimes.any(
                (selectedTime) =>
                    selectedTime.hour == time.hour &&
                    selectedTime.minute == time.minute,
              );
              final canSelect =
                  _reminderTimes.length < _dailyNotificationCount || isSelected;

              return GestureDetector(
                onTap: canSelect ? () => _toggleTimeSelection(time) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF667EEA)
                        : canSelect
                        ? Colors.grey.shade100
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF667EEA)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : canSelect
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          if (_reminderTimes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Seçilen saatler:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reminderTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        color: const Color(0xFF667EEA),
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667EEA),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 3),
                      GestureDetector(
                        onTap: () => _removeReminderTime(index),
                        child: const Icon(
                          FontAwesomeIcons.xmark,
                          color: Color(0xFFEF4444),
                          size: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSnoozeSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.clockRotateLeft,
                color: Color(0xFF667EEA),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Gecikme Ayarları',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Enable/Disable Snooze
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gecikme özelliğini etkinleştir',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
              Switch(
                value: _snoozeEnabled,
                onChanged: (value) {
                  setState(() {
                    _snoozeEnabled = value;
                  });
                },
                activeColor: const Color(0xFF667EEA),
              ),
            ],
          ),

          if (_snoozeEnabled) ...[
            const SizedBox(height: 20),

            // Snooze Duration
            Text(
              'Gecikme Süresi (dakika)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _snoozeDurationMinutes > 5
                      ? () => setState(() => _snoozeDurationMinutes -= 5)
                      : null,
                  icon: const Icon(FontAwesomeIcons.minus),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                    foregroundColor: const Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_snoozeDurationMinutes dk',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: _snoozeDurationMinutes < 60
                      ? () => setState(() => _snoozeDurationMinutes += 5)
                      : null,
                  icon: const Icon(FontAwesomeIcons.plus),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                    foregroundColor: const Color(0xFF667EEA),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Max Snoozes
            Text(
              'Maksimum Gecikme Sayısı',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _maxSnoozes > 1
                      ? () => setState(() => _maxSnoozes--)
                      : null,
                  icon: const Icon(FontAwesomeIcons.minus),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                    foregroundColor: const Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _maxSnoozes.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: _maxSnoozes < 10
                      ? () => setState(() => _maxSnoozes++)
                      : null,
                  icon: const Icon(FontAwesomeIcons.plus),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                    foregroundColor: const Color(0xFF667EEA),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.infoCircle,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'İlaç içmediğinizde $_snoozeDurationMinutes dakika sonra tekrar hatırlatma gelir. Maksimum $_maxSnoozes kez tekrarlanır.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.infoCircle,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gecikme özelliği kapalı. İlaç içmediğinizde tekrar hatırlatma gelmeyecek.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF667EEA), size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null
                      ? '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'
                      : 'Tarih seçin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: date != null
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              FontAwesomeIcons.chevronRight,
              color: const Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
