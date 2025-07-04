import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/incident_report.dart';
import 'api_client.dart';
  import 'package:flutter/material.dart';

class AuthenticationApi {
  // Base URL depending on platform (Web or Android Emulator)
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api' // For web (same machine)
      : 'http://10.0.2.2/api'; // For Android emulator (maps to localhost)

  // Signup API Call
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse('$_baseUrl/controller/User/Signup.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Login API Call - now uses the new ApiClient
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await ApiClient.login(email: email, password: password);
      print('[AuthenticationApi] Login response: ' + result.toString());
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Logout API Call - now uses the new ApiClient
  static Future<Map<String, dynamic>> logout() async {
    try {
      final result = await ApiClient.logout();
      return result;
    } catch (e) {
      // Even if logout API fails, clear local token
      ApiClient.clearAuthToken();
      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    }
  }

  // Validate session with server
  static Future<Map<String, dynamic>> validateSession() async {
    try {
      final token = ApiClient.authToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'No session token found',
          'requiresLogin': true,
        };
      }

      final url = Uri.parse('$_baseUrl/controller/User/ValidateSession.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final result = _handleResponse(response);
      
      if (!result['success']) {
        // Session is invalid, clear local token
        ApiClient.clearAuthToken();
        result['requiresLogin'] = true;
      }
      
      return result;
    } catch (e) {
      // On error, assume session is invalid
      ApiClient.clearAuthToken();
      return {
        'success': false,
        'message': 'Session validation failed: $e',
        'requiresLogin': true,
      };
    }
  }

  // Refresh session token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final token = ApiClient.authToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'No session token found',
          'requiresLogin': true,
        };
      }

      final url = Uri.parse('$_baseUrl/controller/User/RefreshToken.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final result = _handleResponse(response);
      
      if (result['success'] && result['token'] != null) {
        // Store new token
        ApiClient.setAuthToken(result['token']);
      } else {
        // Token refresh failed, clear token
        ApiClient.clearAuthToken();
        result['requiresLogin'] = true;
      }
      
      return result;
    } catch (e) {
      ApiClient.clearAuthToken();
      return {
        'success': false,
        'message': 'Token refresh failed: $e',
        'requiresLogin': true,
      };
    }
  }

  // Get authenticated headers for API calls
  static Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = ApiClient.authToken;
    final headers = {'Content-Type': 'application/json'};
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Helper method to decode and handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}.',
      };
    }
  }

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

  // Change Password API Call
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = ApiClient.authToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'No session token found',
          'requiresLogin': true,
        };
      }
      final url = Uri.parse('$_baseUrl/controller/User/ChangePassword.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Forgot Password API Call
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final url = Uri.parse('$_baseUrl/controller/User/ForgotPassword.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // Verify OTP API Call
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final url = Uri.parse('$_baseUrl/controller/User/VerifyOtp.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Reset Password API Call
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/controller/User/ResetPassword.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'new_password': newPassword}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}


