import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost/api';
  static String? _authToken;

  // Load token from persistent storage
  static Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Set authentication token and persist it
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear authentication token from memory and storage
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get current authentication token (cached, may be null if not loaded)
  static String? get authToken => _authToken;

  // Always fetch the latest token from storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
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
    // print('ApiClient: Sending headers: ' + headers.toString()); // Commented out debug print
    try {
      http.Response response;
      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true;
        switch (method.toUpperCase()) {
          case 'GET':
            response = await client.get(url, headers: headers);
            break;
          case 'POST':
            response = await client.post(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await client.put(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await client.delete(url, headers: headers);
            break;
          default:
            throw Exception('Unsupported HTTP method: $method');
        }
      } else {
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(url, headers: headers);
            break;
          case 'POST':
            response = await http.post(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await http.put(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await http.delete(url, headers: headers);
            break;
          default:
            throw Exception('Unsupported HTTP method: $method');
        }
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          } else {
            return {
              'success': false,
              'message': 'Unexpected response format',
              'body': response.body,
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to parse response: $e',
            'body': response.body,
          };
        }
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          if (errorResponse is Map<String, dynamic>) {
            return errorResponse;
          } else {
            return {
              'success': false,
              'message': 'Unexpected error response format',
              'body': response.body,
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            'body': response.body,
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