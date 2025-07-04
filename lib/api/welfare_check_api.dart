import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/welfare_check.dart';
import '../services/session_service.dart';
import 'authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class WelfareCheckApi {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api'
      : 'http://10.0.2.2/api';

  // Get auth token from SessionService
  static Future<String?> getToken() async {
    return await SessionService.getToken();
  }

  // Build authenticated headers
  static Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (!kIsWeb && token != null) 'Cookie': 'PHPSESSID=$token',
    };
  }



  // Helper method to decode and handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'message': 'Server error: [200m${response.statusCode}[0m.',
      };
    }
  }

  // Fetch active emergencies
  static Future<List<dynamic>> fetchActiveEmergencies() async {
    try {
      final url = Uri.parse('$_baseUrl/controller/Emergencies.php/?is_active=1');
      final headers = await getAuthenticatedHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    await ApiClient.setAuthToken(token);
  }

  // Retrieve token from SharedPreferences
  static Future<String?> getTokenFromPrefs() async {
    return await ApiClient.getToken();
  }

  static Future<Map<String, dynamic>> submitWelfareCheck(Map<String, dynamic> check) async {
    return await ApiClient.submitWelfareCheck(check);
  }

  static Future<bool> hasSubmittedWelfareCheck(int userId, int emergencyId) async {
    return await ApiClient.hasSubmittedWelfareCheck(userId, emergencyId);
  }
} 