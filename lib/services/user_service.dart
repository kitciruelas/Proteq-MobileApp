// import 'package:http/http.dart' as http;  // Removed - causes web package issues
import 'dart:convert';
import 'dart:io';
import '../models/user.dart';
import '../api/authentication.dart';

class UserService {
  static Future<User?> getUserById(int userId) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://your.api.url/api/user/$userId'));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await AuthenticationApi.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
} 