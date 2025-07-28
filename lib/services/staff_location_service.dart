import 'dart:math';
import '../api/staff_location_api.dart';
import '../models/staff.dart';
import '../models/staff_location.dart';

class StaffLocationService {
  // Update staff location with validation
  static Future<Map<String, dynamic>> updateLocation({
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

      final response = await StaffLocationApi.updateLocation(
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
  static Future<Map<String, dynamic>?> getLocation(int staffId) async {
    try {
      final response = await StaffLocationApi.getLocation(staffId);
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting staff location: $e');
      return null;
    }
  }

  // Get staff location as StaffLocation object
  static Future<StaffLocation?> getStaffLocation(int staffId) async {
    try {
      final locationData = await getLocation(staffId);
      if (locationData != null) {
        return StaffLocation.fromJson(locationData);
      }
      return null;
    } catch (e) {
      print('Error getting staff location: $e');
      return null;
    }
  }

  // Get all staff locations
  static Future<List<Map<String, dynamic>>> getAllLocations() async {
    try {
      final response = await StaffLocationApi.getAllLocations();

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

  // Get all staff locations as StaffLocation objects
  static Future<List<StaffLocation>> getAllStaffLocations() async {
    try {
      final locationsData = await getAllLocations();
      return locationsData.map((json) => StaffLocation.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all staff locations: $e');
      return [];
    }
  }

  // Get staff locations by role
  static Future<List<Map<String, dynamic>>> getLocationsByRole(String role) async {
    try {
      final response = await StaffLocationApi.getLocationsByRole(role);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> locationsData = response['data'];
        return locationsData.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting staff locations by role: $e');
      return [];
    }
  }

  // Get staff locations by role as StaffLocation objects
  static Future<List<StaffLocation>> getStaffLocationsByRole(String role) async {
    try {
      final locationsData = await getLocationsByRole(role);
      return locationsData.map((json) => StaffLocation.fromJson(json)).toList();
    } catch (e) {
      print('Error getting staff locations by role: $e');
      return [];
    }
  }

  // Get available staff locations
  static Future<List<Map<String, dynamic>>> getAvailableStaffLocations() async {
    try {
      final response = await StaffLocationApi.getAvailableStaffLocations();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> locationsData = response['data'];
        return locationsData.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting available staff locations: $e');
      return [];
    }
  }

  // Get available staff locations as StaffLocation objects
  static Future<List<StaffLocation>> getAvailableStaffLocationsAsObjects() async {
    try {
      final locationsData = await getAvailableStaffLocations();
      return locationsData.map((json) => StaffLocation.fromJson(json)).toList();
    } catch (e) {
      print('Error getting available staff locations: $e');
      return [];
    }
  }

  // Get staff locations within a radius
  static Future<List<Map<String, dynamic>>> getLocationsWithinRadius({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusInKm,
  }) async {
    try {
      final response = await StaffLocationApi.getLocationsWithinRadius(
        centerLatitude: centerLatitude,
        centerLongitude: centerLongitude,
        radiusInKm: radiusInKm,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> locationsData = response['data'];
        return locationsData.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting staff locations within radius: $e');
      return [];
    }
  }

  // Get staff locations within a radius as StaffLocation objects
  static Future<List<StaffLocation>> getStaffLocationsWithinRadius({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusInKm,
  }) async {
    try {
      final locationsData = await getLocationsWithinRadius(
        centerLatitude: centerLatitude,
        centerLongitude: centerLongitude,
        radiusInKm: radiusInKm,
      );
      return locationsData.map((json) => StaffLocation.fromJson(json)).toList();
    } catch (e) {
      print('Error getting staff locations within radius: $e');
      return [];
    }
  }

  // Get nearest staff to a location
  static Future<List<Map<String, dynamic>>> getNearestStaff({
    required double latitude,
    required double longitude,
    String? role,
    int? limit,
  }) async {
    try {
      final response = await StaffLocationApi.getNearestStaff(
        latitude: latitude,
        longitude: longitude,
        role: role,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> locationsData = response['data'];
        return locationsData.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error getting nearest staff: $e');
      return [];
    }
  }

  // Get nearest staff to a location as StaffLocation objects
  static Future<List<StaffLocation>> getNearestStaffAsObjects({
    required double latitude,
    required double longitude,
    String? role,
    int? limit,
  }) async {
    try {
      final locationsData = await getNearestStaff(
        latitude: latitude,
        longitude: longitude,
        role: role,
        limit: limit,
      );
      return locationsData.map((json) => StaffLocation.fromJson(json)).toList();
    } catch (e) {
      print('Error getting nearest staff: $e');
      return [];
    }
  }

  // Calculate distance between two points using Haversine formula
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Find the nearest staff member to a given location
  static StaffLocation? findNearestStaff({
    required double targetLatitude,
    required double targetLongitude,
    required List<StaffLocation> staffLocations,
    String? requiredRole,
  }) {
    if (staffLocations.isEmpty) return null;

    StaffLocation? nearestStaff;
    double shortestDistance = double.infinity;

    for (final location in staffLocations) {
      // Filter by role if specified
      if (requiredRole != null && location.staffRole.toLowerCase() != requiredRole.toLowerCase()) {
        continue;
      }

      // Skip invalid locations
      if (!location.isValidLocation) continue;

      final double distance = calculateDistance(
        lat1: targetLatitude,
        lon1: targetLongitude,
        lat2: location.latitude,
        lon2: location.longitude,
      );

      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestStaff = location.copyWith(distance: distance);
      }
    }

    return nearestStaff;
  }

  // Get staff locations with distance from a point
  static List<StaffLocation> getStaffLocationsWithDistance({
    required double centerLatitude,
    required double centerLongitude,
    required List<StaffLocation> staffLocations,
  }) {
    return staffLocations.map((location) {
      double distance = 0.0;
      if (location.isValidLocation) {
        distance = calculateDistance(
          lat1: centerLatitude,
          lon1: centerLongitude,
          lat2: location.latitude,
          lon2: location.longitude,
        );
      }

      return location.copyWith(distance: distance);
    }).toList()
      ..sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
  }

  // Validate location data
  static bool isValidLocation({
    required double latitude,
    required double longitude,
  }) {
    return latitude >= -90 && latitude <= 90 && 
           longitude >= -180 && longitude <= 180;
  }

  // Format distance for display
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  // Get staff locations filtered by availability and status
  static List<StaffLocation> filterStaffLocations({
    required List<StaffLocation> staffLocations,
    String? availability,
    String? status,
    String? role,
  }) {
    return staffLocations.where((location) {
      bool matchesAvailability = true;
      bool matchesStatus = true;
      bool matchesRole = true;

      if (availability != null) {
        matchesAvailability = location.availability?.toLowerCase() == availability.toLowerCase();
      }

      if (status != null) {
        matchesStatus = location.status?.toLowerCase() == status.toLowerCase();
      }

      if (role != null) {
        matchesRole = location.staffRole.toLowerCase() == role.toLowerCase();
      }

      return matchesAvailability && matchesStatus && matchesRole;
    }).toList();
  }
} 