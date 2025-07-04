import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/incident_report.dart';
import 'api_client.dart';
import '../services/session_service.dart';

class IncidentReportApi {
  // Base URL depending on platform (Web or Android Emulator)
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api' // For web (same machine)
      : 'http://10.0.2.2/api'; // For Android emulator (maps to localhost)

  // Submit a new incident report - now uses the new ApiClient
  static Future<Map<String, dynamic>> submitIncidentReport(IncidentReport report) async {
    return await ApiClient.createIncidentReport(
      incidentType: report.incidentType,
      description: report.description,
      longitude: report.longitude ?? 0.0,
      latitude: report.latitude ?? 0.0,
      priorityLevel: report.priorityLevel,
      reporterSafeStatus: report.safetyStatus,
    );
  }

  // Returns the appropriate HTTP client depending on the platform
  static http.Client getHttpClient() {
    if (kIsWeb) {
      return BrowserClient();
    } else {
      return http.Client();
    }
  }

  // Handles HTTP responses and returns a Map
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response format: $e',
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    }
  }

  // Legacy method for backward compatibility - POST only
  static Future<Map<String, dynamic>> submitIncidentReportLegacy(IncidentReport report) async {
    try {
      final url = Uri.parse('$_baseUrl/controller/IncidentReport.php');
      final client = getHttpClient();
      final token = ApiClient.authToken;
      final headers = {
        'Content-Type': 'application/json',
        if (!kIsWeb && token != null) 'Cookie': 'PHPSESSID=$token',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(report.toJson()),
      );
      client.close();
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> createIncident(String token, Map<String, dynamic> incidentData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/controller/IncidentReport.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(incidentData),
    );
    // ... your code ...
  }

  static Future<void> storeToken(String token) async {
    await SessionService.storeToken(token);
  }
}