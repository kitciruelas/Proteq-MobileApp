// import 'package:http/http.dart' as http;  // Removed - causes web package issues
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/session_service.dart';
import 'api_client.dart';
import '../models/welfare_check.dart';

class WelfareCheckApi {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api'
      : 'http://192.168.1.10/api';

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
  static Map<String, dynamic> _handleResponse(HttpClientResponse response, String responseBody) {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}.',
      };
    }
  }

  // Fetch active emergencies
  static Future<List<dynamic>> fetchActiveEmergencies() async {
    try {
      final url = Uri.parse('$_baseUrl/controller/Emergencies.php/?is_active=1');
      final headers = await getAuthenticatedHeaders();
      
      final client = HttpClient();
      final request = await client.getUrl(url);
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data is List) {
          return data;
        } else if (data is Map && data['data'] is List) {
          return data['data'];
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load emergencies: Server responded with status code ${response.statusCode}.');
      }
    } catch (e) {
      throw Exception('Failed to load emergencies: ${e.toString()}');
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

  static Future<Map<String, dynamic>?> getUserWelfareCheck(int userId, int emergencyId) async {
    return await ApiClient.getUserWelfareCheck(userId, emergencyId);
  }
} 