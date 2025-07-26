import 'package:flutter/foundation.dart';
import 'api_client.dart';

class EvacuationCenterApi {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api'
      : 'http://192.168.0.102/api';

  // Fetch all evacuation centers
  static Future<Map<String, dynamic>> fetchAllCenters() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/EvacuationCenters.php',
      method: 'GET',
    );
  }

  // Fetch center by ID
  static Future<Map<String, dynamic>> fetchCenterById(int centerId) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/EvacuationCenters.php?action=get_by_id&id=$centerId',
      method: 'GET',
    );
  }

  // Search centers
  static Future<Map<String, dynamic>> searchCenters(String query) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/EvacuationCenters.php?action=search&query=$query',
      method: 'GET',
    );
  }
} 