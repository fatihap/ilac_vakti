class Habit {
  final int? id;
  final String name;
  final String description;
  final String frequencyType; // hourly, daily, weekly, monthly, yearly
  final int frequencyInterval;
  final int targetCount;
  final String? reminderTime;
  final List<int>? reminderDays; // Haftalık için hangi günler (1=Pazartesi, 7=Pazar)
  final String startDate;
  final String? endDate;
  final bool isActive;
  final int currentStreak; // Mevcut seri
  final int longestStreak; // En uzun seri
  final int totalCompletions; // Toplam tamamlama sayısı

  Habit({
    this.id,
    required this.name,
    required this.description,
    required this.frequencyType,
    required this.frequencyInterval,
    required this.targetCount,
    this.reminderTime,
    this.reminderDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      frequencyType: json['frequency_type'] ?? 'daily',
      frequencyInterval: json['frequency_interval'] ?? 1,
      targetCount: json['target_count'] ?? 1,
      reminderTime: json['reminder_time'],
      reminderDays: json['reminder_days'] != null 
          ? List<int>.from(json['reminder_days']) 
          : null,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      isActive: json['is_active'] ?? true,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalCompletions: json['total_completions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency_type': frequencyType,
      'frequency_interval': frequencyInterval,
      'target_count': targetCount,
      'reminder_time': reminderTime,
      'reminder_days': reminderDays,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_completions': totalCompletions,
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

// Alışkanlık güncelleme için request modeli
class UpdateHabitRequest {
  final int? targetCount;
  final String? reminderTime;
  final String? name;
  final String? description;
  final String? frequencyType;
  final int? frequencyInterval;
  final List<int>? reminderDays;
  final String? endDate;
  final bool? isActive;

  UpdateHabitRequest({
    this.targetCount,
    this.reminderTime,
    this.name,
    this.description,
    this.frequencyType,
    this.frequencyInterval,
    this.reminderDays,
    this.endDate,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (targetCount != null) data['target_count'] = targetCount;
    if (reminderTime != null) data['reminder_time'] = reminderTime;
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (frequencyType != null) data['frequency_type'] = frequencyType;
    if (frequencyInterval != null) data['frequency_interval'] = frequencyInterval;
    if (reminderDays != null) data['reminder_days'] = reminderDays;
    if (endDate != null) data['end_date'] = endDate;
    if (isActive != null) data['is_active'] = isActive;
    
    return data;
  }
}

// Alışkanlık tamamlama için request modeli
class CompleteHabitRequest {
  final int count;
  final String? notes;
  final int? rating; // 1-5 arası değerlendirme

  CompleteHabitRequest({
    required this.count,
    this.notes,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'count': count,
    };
    
    if (notes != null && notes!.isNotEmpty) data['notes'] = notes;
    if (rating != null) data['rating'] = rating;
    
    return data;
  }
}

// Alışkanlık kategorileri
enum HabitCategory {
  health('Sağlık', '💊'),
  fitness('Fitness', '🏃‍♂️'),
  nutrition('Beslenme', '🥗'),
  productivity('Verimlilik', '📈'),
  learning('Öğrenme', '📚'),
  mindfulness('Farkındalık', '🧘‍♀️'),
  social('Sosyal', '👥'),
  hobby('Hobi', '🎨'),
  finance('Finans', '💰'),
  other('Diğer', '📝');

  const HabitCategory(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

// Alışkanlık durumu
enum HabitStatus {
  pending('Bekliyor', '⏳'),
  completed('Tamamlandı', '✅'),
  missed('Kaçırıldı', '❌'),
  partiallyCompleted('Kısmen Tamamlandı', '🟡');

  const HabitStatus(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}
