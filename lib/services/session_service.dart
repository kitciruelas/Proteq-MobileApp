import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _lastLoginKey = 'last_login';
  static const String _sessionTimeoutKey = 'session_timeout';
  
  // Default session timeout: 24 hours
  static const Duration _defaultSessionTimeout = Duration(hours: 24);

  // Store authentication token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    print('[SessionService] Token stored. Last login set to: \'${DateTime.now().toIso8601String()}\'');
  }

  // Get stored authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Store user data
  static Future<void> storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get stored user data
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      try {
        return User.fromJson(jsonDecode(userData));
      } catch (e) {
        // If user data is corrupted, clear it
        await clearSession();
        return null;
      }
    }
    return null;
  }

  // Check if user is logged in and session is valid
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) {
      print('[SessionService] No token found. Not logged in.');
      return false;
    }

    // Check if session has expired
    final expired = await _isSessionExpired();
    print('[SessionService] Session expired? $expired');
    if (expired) {
      await clearSession();
      return false;
    }

    return true;
  }

  // Check if session has expired
  static Future<bool> _isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString(_lastLoginKey);
    final timeoutStr = prefs.getString(_sessionTimeoutKey);
    
    if (lastLoginStr == null) {
      print('[SessionService] No last login found. Session expired.');
      return true;
    }

    try {
      final lastLogin = DateTime.parse(lastLoginStr);
      final timeout = timeoutStr != null 
          ? Duration(hours: int.parse(timeoutStr))
          : _defaultSessionTimeout;
      final now = DateTime.now();
      final diff = now.difference(lastLogin);
      print('[SessionService] Now: $now, Last login: $lastLogin, Timeout: $timeout, Elapsed: $diff');
      return diff > timeout;
    } catch (e) {
      print('[SessionService] Error parsing last login or timeout: $e');
      return true;
    }
  }

  // Set custom session timeout
  static Future<void> setSessionTimeout(Duration timeout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTimeoutKey, timeout.inHours.toString());
  }

  // Get session timeout
  static Future<Duration> getSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final timeoutStr = prefs.getString(_sessionTimeoutKey);
    return timeoutStr != null 
        ? Duration(hours: int.parse(timeoutStr))
        : _defaultSessionTimeout;
  }

  // Clear all session data (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_lastLoginKey);
    // Don't remove session timeout as it's a user preference
  }

  // Refresh session (update last login time)
  static Future<void> refreshSession() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_lastLoginKey, now);
    print('[SessionService] Session refreshed. Last login updated to: $now');
  }

  // Get remaining session time
  static Future<Duration?> getRemainingSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString(_lastLoginKey);
    final timeoutStr = prefs.getString(_sessionTimeoutKey);
    
    if (lastLoginStr == null) return null;

    try {
      final lastLogin = DateTime.parse(lastLoginStr);
      final timeout = timeoutStr != null 
          ? Duration(hours: int.parse(timeoutStr))
          : _defaultSessionTimeout;
      
      final now = DateTime.now();
      final elapsed = now.difference(lastLogin);
      final remaining = timeout - elapsed;
      
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return null;
    }
  }

  // Check if session is about to expire (within 5 minutes)
  static Future<bool> isSessionExpiringSoon() async {
    final remaining = await getRemainingSessionTime();
    if (remaining == null) return true;
    
    return remaining.inMinutes <= 5;
  }

  // Get the current user (alias for getUser)
  static Future<User?> getCurrentUser() async {
    return getUser();
  }
} 