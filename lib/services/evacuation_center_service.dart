import '../api/evacuation_center_api.dart';
import '../models/evacuation_center.dart';

class EvacuationCenterService {
  // Fetch all evacuation centers
  static Future<List<EvacuationCenter>> getAllCenters() async {
    try {
      final result = await EvacuationCenterApi.fetchAllCenters();
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> centersData = result['data'];
        return centersData.map((json) => EvacuationCenter.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Fetch center by ID
  static Future<EvacuationCenter?> getCenterById(int centerId) async {
    try {
      final result = await EvacuationCenterApi.fetchCenterById(centerId);
      if (result['success'] == true && result['data'] != null) {
        return EvacuationCenter.fromJson(result['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search centers
  static Future<List<EvacuationCenter>> searchCenters(String query) async {
    try {
      final result = await EvacuationCenterApi.searchCenters(query);
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> centersData = result['data'];
        return centersData.map((json) => EvacuationCenter.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
} 