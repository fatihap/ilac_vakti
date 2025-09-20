class Medication {
  final int? id;
  final String name;
  final String description;
  final String frequencyType; // hourly, daily, weekly, monthly, yearly
  final int frequencyInterval;
  final int targetCount; // Günde kaç defa alınacak
  final String? dosage; // Doz bilgisi (örn: "500mg", "1 tablet")
  final String? reminderTime; // Hatırlatma saati
  final List<String>? reminderTimes; // Birden fazla hatırlatma saati
  final List<String>? allReminderTimes; // Tüm hatırlatma saatleri (API'den gelen)
  final List<int>? reminderDays; // Haftalık için hangi günler (1=Pazartesi, 7=Pazar)
  final String startDate;
  final String? endDate;
  final String? medicationType; // tablet, şurup, damla, kapsül, etc.
  final String? instructions; // Özel talimatlar (yemekten önce/sonra, etc.)
  final bool isActive;
  final bool? isCompletedToday; // Bugün tamamlandı mı?
  final double? todayCompletionPercentage; // Bugünkü tamamlanma yüzdesi
  final String? lastCompletedAt; // Son tamamlanma tarihi

  Medication({
    this.id,
    required this.name,
    required this.description,
    required this.frequencyType,
    required this.frequencyInterval,
    required this.targetCount,
    this.dosage,
    this.reminderTime,
    this.reminderTimes,
    this.allReminderTimes,
    this.reminderDays,
    required this.startDate,
    this.endDate,
    this.medicationType,
    this.instructions,
    this.isActive = true,
    this.isCompletedToday,
    this.todayCompletionPercentage,
    this.lastCompletedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    // Debug: Print raw JSON data
    print('🔍 Raw medication JSON: $json');
    
    // Try to extract reminder times from various possible fields
    List<String>? extractedReminderTimes;
    
    // Check direct fields first
    if (json['reminder_times'] != null) {
      extractedReminderTimes = List<String>.from(json['reminder_times']);
      print('🔍 Found reminder_times: $extractedReminderTimes');
    } else if (json['all_reminder_times'] != null) {
      extractedReminderTimes = List<String>.from(json['all_reminder_times']);
      print('🔍 Found all_reminder_times: $extractedReminderTimes');
    } else if (json['reminder_schedule'] != null) {
      // Check nested reminder_schedule structure
      final reminderSchedule = json['reminder_schedule'];
      if (reminderSchedule is Map && reminderSchedule['times'] != null) {
        extractedReminderTimes = List<String>.from(reminderSchedule['times']);
        print('🔍 Found reminder_schedule.times: $extractedReminderTimes');
      }
    }
    
    return Medication(
      id: _parseId(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      frequencyType: json['frequency_type']?.toString() ?? 'daily',
      frequencyInterval: _parseInt(json['frequency_interval']) ?? 1,
      targetCount: _parseInt(json['target_count']) ?? 1,
      dosage: json['dosage']?.toString(),
      reminderTime: json['reminder_time']?.toString(),
      reminderTimes: extractedReminderTimes,
      allReminderTimes: json['all_reminder_times'] != null 
          ? List<String>.from(json['all_reminder_times'])
          : null,
      reminderDays: json['reminder_days'] != null 
          ? _parseIntList(json['reminder_days'])
          : null,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      medicationType: json['medication_type']?.toString(),
      instructions: json['instructions']?.toString(),
      isActive: _parseBool(json['is_active'] ?? json['status']) ?? true,
      isCompletedToday: _parseBool(json['is_completed_today']),
      todayCompletionPercentage: _parseDouble(json['today_completion_percentage']),
      lastCompletedAt: json['last_completed_at']?.toString(),
    );
  }

  // Helper methods for safe parsing
  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == 'true' || lowerValue == '1' || lowerValue == 'active') return true;
      if (lowerValue == 'false' || lowerValue == '0' || lowerValue == 'inactive') return false;
    }
    if (value is int) return value == 1;
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<int> _parseIntList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => _parseInt(item) ?? 0).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency_type': frequencyType,
      'frequency_interval': frequencyInterval,
      'target_count': targetCount,
      'dosage': dosage,
      'reminder_time': reminderTime,
      'reminder_times': reminderTimes,
      'all_reminder_times': allReminderTimes,
      'reminder_days': reminderDays,
      'start_date': startDate,
      'end_date': endDate,
      'medication_type': medicationType,
      'instructions': instructions,
      'is_active': isActive,
    };
  }

  // Frequency type için Türkçe açıklamalar
  String get frequencyDescription {
    switch (frequencyType) {
      case 'hourly':
        return 'Her $frequencyInterval saatte bir';
      case 'daily':
        return 'Günde $targetCount kez';
      case 'weekly':
        if (reminderDays != null && reminderDays!.isNotEmpty) {
          final dayNames = reminderDays!.map((day) => _getDayName(day)).join(', ');
          return 'Haftada $dayNames günleri';
        }
        return 'Haftada $targetCount kez';
      case 'monthly':
        return 'Ayda $targetCount kez';
      case 'yearly':
        return 'Yılda $targetCount kez';
      default:
        return 'Belirsiz';
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return 'Bilinmeyen';
    }
  }
}

// İlaç ekleme için request modeli
class AddMedicationRequest {
  final String name;
  final String description;
  final String frequencyType;
  final int frequencyInterval;
  final int targetCount;
  final String? dosage;
  final String? reminderTime;
  final List<int>? reminderDays;
  final String startDate;
  final String? endDate;
  final String? medicationType;
  final String? instructions;

  AddMedicationRequest({
    required this.name,
    required this.description,
    required this.frequencyType,
    required this.frequencyInterval,
    required this.targetCount,
    this.dosage,
    this.reminderTime,
    this.reminderDays,
    required this.startDate,
    this.endDate,
    this.medicationType,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'frequency_type': frequencyType,
      'frequency_interval': frequencyInterval,
      'target_count': targetCount,
      'dosage': dosage,
      'reminder_time': reminderTime,
      'reminder_days': reminderDays,
      'start_date': startDate,
      'end_date': endDate,
      'medication_type': medicationType,
      'instructions': instructions,
    };
  }
}

// İlaç türleri enum
enum MedicationType {
  tablet('Tablet'),
  capsule('Kapsül'),
  syrup('Şurup'),
  drops('Damla'),
  injection('Enjeksiyon'),
  cream('Krem'),
  spray('Sprey'),
  powder('Toz'),
  other('Diğer');

  const MedicationType(this.displayName);
  final String displayName;
}

// Sıklık türleri enum
enum FrequencyType {
  hourly('hourly', 'Saatlik'),
  daily('daily', 'Günlük'),
  weekly('weekly', 'Haftalık'),
  monthly('monthly', 'Aylık'),
  yearly('yearly', 'Yıllık');

  const FrequencyType(this.value, this.displayName);
  final String value;
  final String displayName;
}

