// import 'package:http/http.dart' as http;  // Removed - causes web package issues
import 'dart:convert';
import 'dart:io';
import '../models/staff.dart';
import '../api/api_client.dart';

class StaffService {
  static Future<Staff?> getStaffById(int staffId) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/staff/$staffId',
        method: 'GET',
      );

      if (response['success'] == true && response['data'] != null) {
        return Staff.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error getting staff by ID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateStaff(Staff staff) async {
    try {
      // Validate staff data before sending to API
      if (staff.name.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Staff name cannot be empty',
        };
      }
      
      if (staff.email.trim().isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(staff.email)) {
        return {
          'success': false,
          'message': 'Please provide a valid email address',
        };
      }
      
      if (!Staff.isValidRole(staff.role)) {
        return {
          'success': false,
          'message': 'Invalid role selected',
        };
      }
      
      if (!Staff.isValidAvailability(staff.availability)) {
        return {
          'success': false,
          'message': 'Invalid availability status',
        };
      }
      
      if (!Staff.isValidStatus(staff.status)) {
        return {
          'success': false,
          'message': 'Invalid staff status',
        };
      }

      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/User/Staff.php?id=${staff.staffId}',
        method: 'PUT',
        body: staff.toJson(),
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update staff: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateStaffAvailability(int staffId, String availability) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/staff/$staffId/availability',
        method: 'PATCH',
        body: {'availability': availability},
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update availability: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateStaffStatus(int staffId, String status) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/staff/$staffId/status',
        method: 'PATCH',
        body: {'status': status},
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update status: $e',
      };
    }
  }

  static Future<List<Staff>> getAllStaff() async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/staff',
        method: 'GET',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> staffData = response['data'];
        return staffData.map((json) => Staff.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting all staff: $e');
      return [];
    }
  }

  static Future<List<Staff>> getAvailableStaff() async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/staff?availability=available&status=active',
        method: 'GET',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> staffData = response['data'];
        return staffData.map((json) => Staff.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting available staff: $e');
      return [];
    }
  }

  static Future<List<Staff>> getStaffByRole(String role) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/staff?role=$role',
        method: 'GET',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> staffData = response['data'];
        return staffData.map((json) => Staff.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting staff by role: $e');
      return [];
    }
  }

  static Future<Staff?> refreshStaffData(int staffId) async {
    try {
      final response = await ApiClient.authenticatedCall(
         endpoint: '/controller/User/Staff.php?id=$staffId',
        method: 'GET',
      );

      if (response['success'] == true && response['data'] != null) {
        return Staff.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error refreshing staff data: $e');
      return null;
    }
  }
} 