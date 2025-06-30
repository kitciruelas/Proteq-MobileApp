import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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

  // Login API Call
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/controller/User/Logins.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Staff API Call
  // ... existing code ...

  // Helper method to decode and handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'message': 'Server error: {response.statusCode}.',
      };
    }
  }
}


