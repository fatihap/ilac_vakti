import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../constants/app_constants.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  bool _initialized = false;

  /// OneSignal servisini başlat
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // OneSignal'i başlat
      OneSignal.initialize(AppConstants.oneSignalAppId);

      _initialized = true;
      print('✅ OneSignal Service initialized');
    } catch (e) {
      print('❌ OneSignal Service initialization error: $e');
    }
  }

  /// Kullanıcı ID'sini al
  Future<String?> getUserId() async {
    try {
      final deviceState = await OneSignal.User.getOnesignalId();
      print('🔍 OneSignal Device State: $deviceState');
      return deviceState;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  /// Birden fazla tag gönder
  Future<void> sendTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);
      print('✅ Tags sent: $tags');
    } catch (e) {
      print('❌ Error sending tags: $e');
    }
  }

  /// Tag sil
  Future<void> deleteTag(String key) async {
    try {
      OneSignal.User.removeTag(key);
      print('✅ Tag deleted: $key');
    } catch (e) {
      print('❌ Error deleting tag: $e');
    }
  }

  /// Birden fazla tag sil
  Future<void> deleteTags(List<String> keys) async {
    try {
      OneSignal.User.removeTags(keys);
      print('✅ Tags deleted: $keys');
    } catch (e) {
      print('❌ Error deleting tags: $e');
    }
  }

  /// External User ID ayarla (kendi kullanıcı ID'nizle eşleştirmek için)
  Future<void> setExternalUserId(String externalUserId) async {
    try {
      OneSignal.login(externalUserId);
      print('✅ External User ID set: $externalUserId');
    } catch (e) {
      print('❌ Error setting external user ID: $e');
    }
  }

  /// External User ID'yi kaldır
  Future<void> removeExternalUserId() async {
    try {
      OneSignal.logout();
      print('✅ External User ID removed');
    } catch (e) {
      print('❌ Error removing external user ID: $e');
    }
  }

  /// Bildirim izni durumunu kontrol et
  Future<bool> hasNotificationPermission() async {
    try {
      final permission = OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      print('❌ Error checking notification permission: $e');
      return false;
    }
  }

  /// Bildirim izni iste
  Future<void> requestNotificationPermission() async {
    try {
      OneSignal.Notifications.requestPermission(true);
      print('✅ Notification permission requested');
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
    }
  }

  /// Kullanıcı giriş yaptığında çağrılacak
  Future<void> onUserLogin(String userId, {String? email, String? name}) async {
    try {
      // External User ID ayarla
      await setExternalUserId(userId);

      // Kullanıcı bilgilerini tag olarak gönder
      final tags = <String, String>{
        'user_id': userId,
        'login_status': 'logged_in',
      };

      if (email != null) {
        tags['email'] = email;
      }

      if (name != null) {
        tags['name'] = name;
      }

      await sendTags(tags);

      print('✅ User login processed for OneSignal: $userId');
    } catch (e) {
      print('❌ Error processing user login: $e');
    }
  }

  /// Kullanıcı çıkış yaptığında çağrılacak
  Future<void> onUserLogout() async {
    try {
      // External User ID'yi kaldır
      await removeExternalUserId();

      // Login durumunu güncelle

      // Hassas bilgileri sil
      await deleteTags(['user_id', 'email', 'name']);

      print('✅ User logout processed for OneSignal');
    } catch (e) {
      print('❌ Error processing user logout: $e');
    }
  }

  /// İlaç ekleme olayını kaydet
  Future<void> onMedicationAdded(
    String medicationName,
    String medicationType,
  ) async {
    try {
      await sendTags({
        'last_medication_added': medicationName,
        'last_medication_type': medicationType,
        'medication_count': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      print('✅ Medication added event recorded: $medicationName');
    } catch (e) {
      print('❌ Error recording medication added: $e');
    }
  }

  /// İlaç alma olayını kaydet
  Future<void> onMedicationTaken(String medicationName) async {
    try {
      await sendTags({
        'last_medication_taken': medicationName,
        'last_taken_time': DateTime.now().toIso8601String(),
      });

      print('✅ Medication taken event recorded: $medicationName');
    } catch (e) {
      print('❌ Error recording medication taken: $e');
    }
  }

  /// Test bildirimi gönder (sadece kendi cihazınıza)
  Future<void> sendTestNotification() async {
    try {
      final userId = await getUserId();
      if (userId != null) {
        // Bu işlem backend'den yapılmalı, burada sadece log yazıyoruz
        print('📱 Test notification would be sent to: $userId');
        print('💡 Use OneSignal dashboard or API to send actual notifications');
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }
}
