import '../models/alert.dart';
import '../api/alerts_api.dart';

class AlertsService {
  // Get latest active alert
  static Future<Alert?> getLatestAlert() async {
    try {
      final response = await AlertsApi.getLatestActiveAlert();
      
      if (response['success'] == true && response['data'] != null) {
        return Alert.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      print('Error fetching latest alert: $e');
      return null;
    }
  }

  // Get all active alerts
  static Future<List<Alert>> getActiveAlerts() async {
    try {
      final response = await AlertsApi.getAllActiveAlerts();
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> alertsData = response['data'];
        return alertsData.map((json) => Alert.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching active alerts: $e');
      return [];
    }
  }

  // Get alert by ID
  static Future<Alert?> getAlertById(int alertId) async {
    try {
      final response = await AlertsApi.getAlertById(alertId);
      
      if (response['success'] == true && response['data'] != null) {
        return Alert.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      print('Error fetching alert by ID: $e');
      return null;
    }
  }

  // Get alerts by type
  static Future<List<Alert>> getAlertsByType(String alertType) async {
    try {
      final response = await AlertsApi.getAlertsByType(alertType);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> alertsData = response['data'];
        return alertsData.map((json) => Alert.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching alerts by type: $e');
      return [];
    }
  }

  // Get emergency alerts
  static Future<List<Alert>> getEmergencyAlerts() async {
    try {
      final response = await AlertsApi.getEmergencyAlerts();
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> alertsData = response['data'];
        return alertsData.map((json) => Alert.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching emergency alerts: $e');
      return [];
    }
  }

  // Get drill alerts
  static Future<List<Alert>> getDrillAlerts() async {
    try {
      final response = await AlertsApi.getDrillAlerts();
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> alertsData = response['data'];
        return alertsData.map((json) => Alert.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching drill alerts: $e');
      return [];
    }
  }

  // Get info alerts
  static Future<List<Alert>> getInfoAlerts() async {
    try {
      final response = await AlertsApi.getInfoAlerts();
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> alertsData = response['data'];
        return alertsData.map((json) => Alert.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching info alerts: $e');
      return [];
    }
  }

  // Get warning alerts
  static Future<List<Alert>> getWarningAlerts() async {
    try {
      final response = await AlertsApi.getWarningAlerts();
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> alertsData = response['data'];
        return alertsData.map((json) => Alert.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching warning alerts: $e');
      return [];
    }
  }
} 