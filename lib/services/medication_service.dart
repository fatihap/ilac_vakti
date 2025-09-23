import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/medication_model.dart';

class MedicationService {
  static const String _baseUrl = AppConstants.baseUrl;
  
  // API Endpoints (using habits API for medications)
  static const String _medicationsEndpoint = AppConstants.habitsEndpoint;
  static const String _addMedicationEndpoint = AppConstants.habitsEndpoint;
  static const String _updateMedicationEndpoint = AppConstants.habitUpdateEndpoint;
  static const String _deleteMedicationEndpoint = AppConstants.habitDeleteEndpoint;

  // Authorization header'ını al
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    
    print('🔑 Retrieved token from storage: ${token != null ? "✅ Found (${token.substring(0, 20)}...)" : "❌ Not found"}');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    print('📤 Request headers: ${headers.keys.toList()}');
    if (token != null) {
      print('🔐 Authorization header: Bearer ${token.substring(0, 20)}...');
    }
    
    return headers;
  }

  // Tüm ilaçları getir
  Future<Map<String, dynamic>> getMedications() async {
    try {
      final headers = await _getHeaders();
      print('🔍 API Request: GET $_medicationsEndpoint');
      print('🔑 Headers: $headers');
      
      final response = await http.get(
        Uri.parse(_medicationsEndpoint),
        headers: headers,
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // API response yapısını kontrol et
        print('📊 Response Data Keys: ${responseData.keys.toList()}');
        
        // API response'da habits key'i var
        List<dynamic> medicationsJson = [];
        
        if (responseData['habits'] != null) {
          medicationsJson = responseData['habits'] as List<dynamic>;
          print('✅ Found data in "habits" key: ${medicationsJson.length} items');
        } else if (responseData['data'] != null) {
          medicationsJson = responseData['data'] as List<dynamic>;
          print('✅ Found data in "data" key: ${medicationsJson.length} items');
        } else if (responseData['medications'] != null) {
          medicationsJson = responseData['medications'] as List<dynamic>;
          print('✅ Found data in "medications" key: ${medicationsJson.length} items');
        } else if (responseData is List) {
          medicationsJson = responseData as List<dynamic>;
          print('✅ Response is direct array: ${medicationsJson.length} items');
        } else {
          print('❌ No medication data found in response');
          print('📋 Available keys: ${responseData.keys.toList()}');
        }
        
        print('🔢 Parsing ${medicationsJson.length} medications...');
        
        final medications = medicationsJson
            .map((json) {
              print('📝 Parsing medication: $json');
              return Medication.fromJson(json);
            })
            .toList();

        print('✅ Successfully parsed ${medications.length} medications');

        return {
          'success': true,
          'medications': medications,
          'message': 'İlaçlar başarıyla getirildi',
        };
      } else {
        print('❌ API Error: ${response.statusCode} - ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'İlaçlar getirilemedi',
          'medications': <Medication>[],
        };
      }
    } catch (e) {
      print('💥 Exception in getMedications: $e');
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
        'medications': <Medication>[],
      };
    }
  }

  // Yeni ilaç ekle
  Future<Map<String, dynamic>> addMedication(dynamic request) async {
    try {
      final headers = await _getHeaders();
      
      // Handle both old AddMedicationRequest and new Map structure
      final requestBody = request is Map<String, dynamic> 
          ? request 
          : request.toJson();
      
      print('📤 Sending medication request to: $_addMedicationEndpoint');
      print('📤 Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(_addMedicationEndpoint),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'İlaç başarıyla eklendi',
          'data': responseData['data'] ?? responseData['habit'],
          'medication': responseData['data'] != null 
              ? Medication.fromJson(responseData['data']) 
              : responseData['habit'] != null
                  ? Medication.fromJson(responseData['habit'])
                  : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'İlaç eklenemedi',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('💥 Exception in addMedication: $e');
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // İlaç güncelle
  Future<Map<String, dynamic>> updateMedication(int medicationId, dynamic request) async {
    try {
      final headers = await _getHeaders();
      
      // Handle both old AddMedicationRequest and new Map structure
      final requestBody = request is Map<String, dynamic> 
          ? request 
          : request.toJson();
      
      print('📤 Updating medication $medicationId');
      print('📤 Request body: $requestBody');
      
      final response = await http.put(
        Uri.parse('$_updateMedicationEndpoint/$medicationId'),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'İlaç başarıyla güncellendi',
          'data': responseData['data'] ?? responseData['habit'],
          'medication': responseData['data'] != null 
              ? Medication.fromJson(responseData['data']) 
              : responseData['habit'] != null
                  ? Medication.fromJson(responseData['habit'])
                  : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'İlaç güncellenemedi',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('💥 Exception in updateMedication: $e');
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // İlaç sil
  Future<Map<String, dynamic>> deleteMedication(int medicationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_deleteMedicationEndpoint/$medicationId'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'İlaç başarıyla silindi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'İlaç silinemedi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // Belirli bir ilacı getir
  Future<Map<String, dynamic>> getMedication(int medicationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_medicationsEndpoint/$medicationId'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'medication': Medication.fromJson(responseData['data'] ?? responseData),
          'message': 'İlaç başarıyla getirildi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'İlaç getirilemedi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // Bugünkü ilaçları getir
  Future<Map<String, dynamic>> getTodaysMedications() async {
    try {
      final headers = await _getHeaders();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      print('🔍 API Request: GET $_medicationsEndpoint/today?date=$today');
      print('🔑 Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$_medicationsEndpoint/today?date=$today'),
        headers: headers,
      );

      print('📡 Today Response Status: ${response.statusCode}');
      print('📄 Today Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // API response'da habits key'i var
        List<dynamic> medicationsJson = [];
        
        if (responseData['habits'] != null) {
          medicationsJson = responseData['habits'] as List<dynamic>;
          print('✅ Found today data in "habits" key: ${medicationsJson.length} items');
        } else if (responseData['data'] != null) {
          medicationsJson = responseData['data'] as List<dynamic>;
          print('✅ Found today data in "data" key: ${medicationsJson.length} items');
        } else if (responseData['medications'] != null) {
          medicationsJson = responseData['medications'] as List<dynamic>;
          print('✅ Found today data in "medications" key: ${medicationsJson.length} items');
        } else if (responseData is List) {
          medicationsJson = responseData as List<dynamic>;
          print('✅ Today response is direct array: ${medicationsJson.length} items');
        } else {
          print('❌ No today medication data found');
          print('📋 Available keys: ${responseData.keys.toList()}');
        }
        
        final medications = medicationsJson
            .map((json) => Medication.fromJson(json))
            .toList();

        return {
          'success': true,
          'medications': medications,
          'message': 'Bugünkü ilaçlar başarıyla getirildi',
        };
      } else {
        print('❌ Today API Error: ${response.statusCode} - ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Bugünkü ilaçlar getirilemedi',
          'medications': <Medication>[],
        };
      }
    } catch (e) {
      print('💥 Exception in getTodaysMedications: $e');
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
        'medications': <Medication>[],
      };
    }
  }

  // İlaç alma durumunu işaretle (habits API structure)
  Future<Map<String, dynamic>> markMedicationTaken(int medicationId, String date, String time) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.habitCompleteEndpoint}/$medicationId/complete'),
        headers: headers,
        body: json.encode({
          'count': 1,
          'notes': 'İlaç alındı - $date $time',
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'İlaç alındı olarak işaretlendi',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'İşlem başarısız',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // Belirli bir tarih için ilaç durumlarını getir
  Future<Map<String, dynamic>> getMedicationsForDate(String date) async {
    try {
      final headers = await _getHeaders();
      print('🔍 API Request: GET $_medicationsEndpoint/date/$date');
      print('🔑 Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$_medicationsEndpoint/date/$date'),
        headers: headers,
      );

      print('📡 Date Response Status: ${response.statusCode}');
      print('📄 Date Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        List<dynamic> medicationsJson = [];
        
        if (responseData['habits'] != null) {
          medicationsJson = responseData['habits'] as List<dynamic>;
          print('✅ Found date data in "habits" key: ${medicationsJson.length} items');
        } else if (responseData['data'] != null) {
          medicationsJson = responseData['data'] as List<dynamic>;
          print('✅ Found date data in "data" key: ${medicationsJson.length} items');
        } else if (responseData['medications'] != null) {
          medicationsJson = responseData['medications'] as List<dynamic>;
          print('✅ Found date data in "medications" key: ${medicationsJson.length} items');
        } else if (responseData is List) {
          medicationsJson = responseData as List<dynamic>;
          print('✅ Date response is direct array: ${medicationsJson.length} items');
        } else {
          print('❌ No date medication data found');
          print('📋 Available keys: ${responseData.keys.toList()}');
        }
        
        final medications = medicationsJson
            .map((json) => Medication.fromJson(json))
            .toList();

        return {
          'success': true,
          'medications': medications,
          'message': '$date tarihi için ilaçlar başarıyla getirildi',
        };
      } else {
        print('❌ Date API Error: ${response.statusCode} - ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? '$date tarihi için ilaçlar getirilemedi',
          'medications': <Medication>[],
        };
      }
    } catch (e) {
      print('💥 Exception in getMedicationsForDate: $e');
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
        'medications': <Medication>[],
      };
    }
  }

  // Belirli bir tarih için ilaç alım durumlarını getir
  Future<Map<String, dynamic>> getMedicationTrackingForDate(String date) async {
    try {
      final headers = await _getHeaders();
      print('🔍 API Request: GET $_medicationsEndpoint/tracking/$date');
      print('🔑 Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$_medicationsEndpoint/tracking/$date'),
        headers: headers,
      );

      print('📡 Tracking Response Status: ${response.statusCode}');
      print('📄 Tracking Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'tracking': responseData['tracking'] ?? responseData['data'] ?? {},
          'message': '$date tarihi için takip verileri başarıyla getirildi',
        };
      } else {
        print('❌ Tracking API Error: ${response.statusCode} - ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? '$date tarihi için takip verileri getirilemedi',
          'tracking': <String, dynamic>{},
        };
      }
    } catch (e) {
      print('💥 Exception in getMedicationTrackingForDate: $e');
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
        'tracking': <String, dynamic>{},
      };
    }
  }
}
