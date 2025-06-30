import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/staff.dart';

class StaffService {
  static Future<Staff> fetchStaff(int staffId) async {
    // TODO: Replace with your actual API endpoint
    final response = await http.get(Uri.parse('https://your.api.url/api/staff/staffId'));
    if (response.statusCode == 200) {
      return Staff.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load staff');
    }
  }
} 