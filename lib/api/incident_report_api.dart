import 'dart:convert';
import 'dart:io';
// import 'package:http/http.dart' as http;  // Removed - causes web package issues
// import 'package:http/browser_client.dart';  // Removed - causes web package issues
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/incident_report.dart';
import 'api_client.dart';
import '../services/session_service.dart';

class IncidentReportApi {
  // Base URL depending on platform (Web or Android Emulator)
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api' // For web (same machine)
      : 'http://192.168.1.2/api'; // For Android emulator (maps to localhost)

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
  static HttpClient getHttpClient() {
    return HttpClient();
  }

  // Handles HTTP responses and returns a Map
  static Map<String, dynamic> _handleResponse(HttpClientResponse response, String responseBody) {
    if (response.statusCode == 200) {
      try {
        return jsonDecode(responseBody) as Map<String, dynamic>;
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
      
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      if (!kIsWeb && token != null) {
        request.headers.set('Cookie', 'PHPSESSID=$token');
      }
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      
      request.write(jsonEncode(report.toJson()));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      return _handleResponse(response, responseBody);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<void> saveToken(String token) async {
    await SessionService.storeToken(token);
  }

  static Future<String?> getToken() async {
    return await SessionService.getToken();
  }

  static Future<void> createIncident(String token, Map<String, dynamic> incidentData) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$_baseUrl/controller/IncidentReport.php'));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $token');
      request.write(jsonEncode(incidentData));
      final response = await request.close();
      // Handle response as needed
      client.close();
    } catch (e) {
      // Handle error
    }
  }

  static Future<void> storeToken(String token) async {
    await SessionService.storeToken(token);
  }
}