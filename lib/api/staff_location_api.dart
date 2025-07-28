import '../api/api_client.dart';

class StaffLocationApi {
  // Update staff location
  static Future<Map<String, dynamic>> updateLocation({
    required int staffId,
    required double latitude,
    required double longitude,
    String? address,
    String? timestamp,
  }) async {
    return await ApiClient.updateStaffLocation(
      staffId: staffId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      timestamp: timestamp,
    );
  }

  // Get staff location
  static Future<Map<String, dynamic>> getLocation(int staffId) async {
    return await ApiClient.getStaffLocation(staffId);
  }

  // Get all staff locations
  static Future<Map<String, dynamic>> getAllLocations() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/StaffLocation.php?get_all=1',
      method: 'GET',
    );
  }

  // Get staff locations by role
  static Future<Map<String, dynamic>> getLocationsByRole(String role) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/StaffLocation.php?role=$role',
      method: 'GET',
    );
  }

  // Get available staff locations (staff who are available and active)
  static Future<Map<String, dynamic>> getAvailableStaffLocations() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/StaffLocation.php?availability=available&status=active',
      method: 'GET',
    );
  }

  // Get staff locations within a radius
  static Future<Map<String, dynamic>> getLocationsWithinRadius({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusInKm,
  }) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/StaffLocation.php?radius_search=1&lat=$centerLatitude&lng=$centerLongitude&radius=$radiusInKm',
      method: 'GET',
    );
  }

  // Get nearest staff to a location
  static Future<Map<String, dynamic>> getNearestStaff({
    required double latitude,
    required double longitude,
    String? role,
    int? limit,
  }) async {
    String endpoint = '/controller/StaffLocation.php?nearest=1&lat=$latitude&lng=$longitude';
    if (role != null) {
      endpoint += '&role=$role';
    }
    if (limit != null) {
      endpoint += '&limit=$limit';
    }

    return await ApiClient.authenticatedCall(
      endpoint: endpoint,
      method: 'GET',
    );
  }
} 