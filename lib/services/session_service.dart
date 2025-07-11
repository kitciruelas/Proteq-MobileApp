import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _lastLoginKey = 'last_login';
  static const String _sessionTimeoutKey = 'session_timeout';
  
  // Default session timeout: 24 hours
  static const Duration _defaultSessionTimeout = Duration(hours: 24);

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
      print('[SessionService] Error reading session data: $e');
    }
    return {};
  }

  // Write session data to file
  static Future<void> _writeSessionData(Map<String, dynamic> data) async {
    try {
      final file = await _getSessionFile();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('[SessionService] Error writing session data: $e');
    }
  }

  // Store authentication token
  static Future<void> storeToken(String token) async {
    final data = await _readSessionData();
    data[_tokenKey] = token;
    data[_lastLoginKey] = DateTime.now().toIso8601String();
    await _writeSessionData(data);
    print('[SessionService] Token stored. Last login set to: \'${DateTime.now().toIso8601String()}\'');
  }

  // Get stored authentication token
  static Future<String?> getToken() async {
    final data = await _readSessionData();
    return data[_tokenKey] as String?;
  }

  // Store user data
  static Future<void> storeUser(User user) async {
    final data = await _readSessionData();
    data[_userKey] = user.toJson();
    await _writeSessionData(data);
  }

  // Get stored user data
  static Future<User?> getUser() async {
    final data = await _readSessionData();
    final userData = data[_userKey];
    if (userData != null) {
      try {
        return User.fromJson(userData as Map<String, dynamic>);
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
    final data = await _readSessionData();
    final lastLoginStr = data[_lastLoginKey] as String?;
    final timeoutStr = data[_sessionTimeoutKey] as String?;
    
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
    final data = await _readSessionData();
    data[_sessionTimeoutKey] = timeout.inHours.toString();
    await _writeSessionData(data);
  }

  // Get session timeout
  static Future<Duration> getSessionTimeout() async {
    final data = await _readSessionData();
    final timeoutStr = data[_sessionTimeoutKey] as String?;
    return timeoutStr != null 
        ? Duration(hours: int.parse(timeoutStr))
        : _defaultSessionTimeout;
  }

  // Clear all session data (logout)
  static Future<void> clearSession() async {
    final data = await _readSessionData();
    data.remove(_tokenKey);
    data.remove(_userKey);
    data.remove(_lastLoginKey);
    // Don't remove session timeout as it's a user preference
    await _writeSessionData(data);
  }

  // Refresh session (update last login time)
  static Future<void> refreshSession() async {
    final data = await _readSessionData();
    final now = DateTime.now().toIso8601String();
    data[_lastLoginKey] = now;
    await _writeSessionData(data);
    print('[SessionService] Session refreshed. Last login updated to: $now');
  }

  // Get remaining session time
  static Future<Duration?> getRemainingSessionTime() async {
    final data = await _readSessionData();
    final lastLoginStr = data[_lastLoginKey] as String?;
    final timeoutStr = data[_sessionTimeoutKey] as String?;
    
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