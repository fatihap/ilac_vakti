import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/habit_model.dart';

class HabitService {
  static const String _baseUrl = AppConstants.baseUrl;

  // Authorization header'ını al
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Tüm alışkanlıkları getir
  Future<Map<String, dynamic>> getHabits() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppConstants.habitsEndpoint),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> habitsJson =
            responseData['data'] ?? responseData['habits'] ?? [];
        final habits = habitsJson.map((json) => Habit.fromJson(json)).toList();

        return {
          'success': true,
          'habits': habits,
          'message': 'Alışkanlıklar başarıyla getirildi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Alışkanlıklar getirilemedi',
          'habits': <Habit>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
        'habits': <Habit>[],
      };
    }
  }

  // Belirli bir alışkanlığı getir
  Future<Map<String, dynamic>> getHabit(int habitId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.habitsEndpoint}/$habitId'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'habit': Habit.fromJson(responseData['data'] ?? responseData),
          'message': 'Alışkanlık başarıyla getirildi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Alışkanlık getirilemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Alışkanlık güncelle
  Future<Map<String, dynamic>> updateHabit(
    int habitId,
    UpdateHabitRequest request,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConstants.habitUpdateEndpoint}/$habitId'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Alışkanlık başarıyla güncellendi',
          'habit': responseData['data'] != null
              ? Habit.fromJson(responseData['data'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Alışkanlık güncellenemedi',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Alışkanlık sil
  Future<Map<String, dynamic>> deleteHabit(int habitId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.habitDeleteEndpoint}/$habitId'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Alışkanlık başarıyla silindi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Alışkanlık silinemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Alışkanlık tamamla
  Future<Map<String, dynamic>> completeHabit(
    int habitId,
    CompleteHabitRequest request,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.habitCompleteEndpoint}/$habitId/complete'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Alışkanlık başarıyla tamamlandı',
          'habit': responseData['data'] != null
              ? Habit.fromJson(responseData['data'])
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Alışkanlık tamamlanamadı',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Bugünkü alışkanlıkları getir
  Future<Map<String, dynamic>> getTodaysHabits() async {
    try {
      final headers = await _getHeaders();
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse('${AppConstants.habitsEndpoint}/today?date=$today'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> habitsJson =
            responseData['data'] ?? responseData['habits'] ?? [];
        final habits = habitsJson.map((json) => Habit.fromJson(json)).toList();

        return {
          'success': true,
          'habits': habits,
          'message': 'Bugünkü alışkanlıklar başarıyla getirildi',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Bugünkü alışkanlıklar getirilemedi',
          'habits': <Habit>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
        'habits': <Habit>[],
      };
    }
  }

  // Alışkanlık istatistiklerini getir
  Future<Map<String, dynamic>> getHabitStats(int habitId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.habitsEndpoint}/$habitId/stats'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'stats': responseData['data'] ?? responseData,
          'message': 'İstatistikler başarıyla getirildi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'İstatistikler getirilemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Haftalık alışkanlık durumunu getir
  Future<Map<String, dynamic>> getWeeklyProgress(int habitId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.habitsEndpoint}/$habitId/weekly'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'progress': responseData['data'] ?? responseData,
          'message': 'Haftalık ilerleme başarıyla getirildi',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Haftalık ilerleme getirilemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }
}
