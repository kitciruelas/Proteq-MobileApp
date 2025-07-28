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

  // Update staff location
  static Future<Map<String, dynamic>> updateStaffLocation({
    required int staffId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      // Validate coordinates
      if (latitude < -90 || latitude > 90) {
        return {
          'success': false,
          'message': 'Invalid latitude value. Must be between -90 and 90.',
        };
      }
      
      if (longitude < -180 || longitude > 180) {
        return {
          'success': false,
          'message': 'Invalid longitude value. Must be between -180 and 180.',
        };
      }

      final response = await ApiClient.updateStaffLocation(
        staffId: staffId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        timestamp: DateTime.now().toIso8601String(),
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update staff location: $e',
      };
    }
  }

  // Get staff location
  static Future<Map<String, dynamic>?> getStaffLocation(int staffId) async {
    try {
      final response = await ApiClient.getStaffLocation(staffId);
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting staff location: $e');
      return null;
    }
  }

  // Get all staff locations
  static Future<List<Map<String, dynamic>>> getAllStaffLocations() async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffLocation.php?get_all=1',
        method: 'GET',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> locationsData = response['data'];
        return locationsData.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting all staff locations: $e');
      return [];
    }
  }
} 