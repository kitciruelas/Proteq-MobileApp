// import 'package:http/http.dart' as http;  // Removed - causes web package issues
import 'dart:convert';
import 'dart:io';
import '../models/staff.dart';

class StaffService {
  static Future<Staff?> getStaffById(int staffId) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://your.api.url/api/staff/$staffId'));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return Staff.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 