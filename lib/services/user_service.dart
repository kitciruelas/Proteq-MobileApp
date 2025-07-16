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
    required int staffId,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await AuthenticationApi.changePassword(
      staffId: staffId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  static Future<Map<String, dynamic>> changeUserPassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await AuthenticationApi.changeUserPassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  static Future<void> updateUser(User user) async {
    final url = 'http://192.168.1.2/api/controller/User/UpdateProfile.php'; // Update to your actual API URL if needed
    final client = HttpClient();
    final request = await client.putUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode(jsonEncode(user.toJson())));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    client.close();

    final data = jsonDecode(responseBody);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update user');
    }
  }
} 