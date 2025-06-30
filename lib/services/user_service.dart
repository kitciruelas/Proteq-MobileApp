import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static Future<User> fetchUser(int userId) async {
    // TODO: Replace with your actual API endpoint
    final response = await http.get(Uri.parse('https://your.api.url/api/user/[3m$userId[23m'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }
} 