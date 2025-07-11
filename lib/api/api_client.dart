import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;  // Removed - causes web package issues
// import 'package:http/browser_client.dart';  // Removed - causes web package issues
import 'package:path_provider/path_provider.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.1.12/api';
  static String? _authToken;

  // Get the session file
  static Future<File> _getSessionFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/session_data.json');
  }

  // Read session data from file
  static Future<Map<String, dynamic>> _readSessionData() async {
    try {
      final file = await _getSessionFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      print('[ApiClient] Error reading session data: $e');
    }
    return {};
  }

  // Get stored authentication token
  static Future<String?> _getToken() async {
    final data = await _readSessionData();
    return data['auth_token'] as String?;
  }

  // Load token from persistent storage
  static Future<void> loadToken() async {
    _authToken = await _getToken();
  }

  // Set authentication token and persist it
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final data = await _readSessionData();
    data['auth_token'] = token;
    await _writeSessionData(data);
  }

  // Write session data to file
  static Future<void> _writeSessionData(Map<String, dynamic> data) async {
    try {
      final file = await _getSessionFile();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('[ApiClient] Error writing session data: $e');
    }
  }

  // Clear authentication token from memory and storage
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final data = await _readSessionData();
    data.remove('auth_token');
    await _writeSessionData(data);
  }

  // Get current authentication token (cached, may be null if not loaded)
  static String? get authToken => _authToken;

  // Always fetch the latest token from storage
  static Future<String?> getToken() async {
    return await _getToken();
  }

  // Build authenticated headers
  static Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login method for PHP backend
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _makeRequest(
        endpoint: '/controller/User/Logins.php',
        method: 'POST',
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );

      if (response['success'] == true && response['token'] != null) {
        await setAuthToken(response['token']);
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Create incident report (requires authentication)
  static Future<Map<String, dynamic>> createIncidentReport({
    required String incidentType,
    required String description,
    required double longitude,
    required double latitude,
    String? priorityLevel,
    String? reporterSafeStatus,
  }) async {
    if (_authToken == null) {
      return {
        'success': false,
        'message': 'Authentication required. Please login first.',
      };
    }

    try {
      final response = await _makeRequest(
        endpoint: '/controller/IncidentReport.php',
        method: 'POST',
        body: {
          'incident_type': incidentType,
          'description': description,
          'longitude': longitude,
          'latitude': latitude,
          if (priorityLevel != null) 'priority_level': priorityLevel,
          if (reporterSafeStatus != null) 'safety_status': reporterSafeStatus,
        },
        requiresAuth: true,
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create incident report: ${e.toString()}',
      };
    }
  }

  // Logout method
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _makeRequest(
        endpoint: '/controller/User/Logout.php',
        method: 'POST',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        await clearAuthToken();
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Logout failed: ${e.toString()}',
      };
    }
  }

  // Helper to check if session is invalid and clear token
  static Future<void> _handleSessionInvalid(Map<String, dynamic> response) async {
    if (response['success'] == false &&
        (response['message']?.toString().toLowerCase().contains('invalid') == true ||
         response['message']?.toString().toLowerCase().contains('expired') == true)) {
      await clearAuthToken();
    }
  }

  // Check session status
  static Future<Map<String, dynamic>> checkSessionStatus() async {
    try {
      final response = await _makeRequest(
        endpoint: '/controller/User/SessionStatus.php',
        method: 'GET',
        requiresAuth: true,
      );
      await _handleSessionInvalid(response);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to check session status: [31m${e.toString()}[0m',
      };
    }
  }

  // Make authenticated API call with automatic session handling
  static Future<Map<String, dynamic>> authenticatedCall({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      if (_authToken == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please login first.',
          'requiresLogin': true,
        };
      }
      final response = await _makeRequest(
        endpoint: endpoint,
        method: method,
        body: body,
        requiresAuth: true,
      );
      await _handleSessionInvalid(response);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'API call failed: $e',
      };
    }
  }

  // Helper method to make HTTP requests
  static Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    try {
      final client = HttpClient();
      HttpClientRequest request;
      
      switch (method.toUpperCase()) {
        case 'GET':
          request = await client.getUrl(url);
          break;
        case 'POST':
          request = await client.postUrl(url);
          break;
        case 'PUT':
          request = await client.putUrl(url);
          break;
        case 'DELETE':
          request = await client.deleteUrl(url);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      // Add headers
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
      
      // Add body for POST/PUT requests
      if (body != null && (method.toUpperCase() == 'POST' || method.toUpperCase() == 'PUT')) {
        request.write(jsonEncode(body));
      }
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          } else {
            return {
              'success': false,
              'message': 'Unexpected response format',
              'body': responseBody,
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to parse response: $e',
            'body': responseBody,
          };
        }
      } else {
        try {
          final errorResponse = jsonDecode(responseBody);
          if (errorResponse is Map<String, dynamic>) {
            return errorResponse;
          } else {
            return {
              'success': false,
              'message': 'Unexpected error response format',
              'body': responseBody,
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            'body': responseBody,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> submitWelfareCheck(Map<String, dynamic> check) async {
    return await authenticatedCall(
      endpoint: '/controller/WelfareCheck.php',
      method: 'POST',
      body: check,
    );
  }

  static Future<bool> hasSubmittedWelfareCheck(int userId, int emergencyId) async {
    final response = await authenticatedCall(
      endpoint: '/controller/WelfareCheck.php?user_id=$userId&emergency_id=$emergencyId',
      method: 'GET',
    );
    if (response['success'] == true && response['data'] is List && response['data'].isNotEmpty) {
      return true;
    }
    return false;
  }
} 