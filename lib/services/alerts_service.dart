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
      print('AlertsService: Calling AlertsApi.getEmergencyAlerts()');
      final response = await AlertsApi.getEmergencyAlerts();
      print('AlertsService: Response received: $response');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> alertsData = response['data'];
        print('AlertsService: Found ${alertsData.length} alerts in response');
        return alertsData.map((json) => Alert.fromJson(json)).toList();
      } else {
        print('AlertsService: No emergency alerts found, trying to get all active alerts...');
        // Fallback: Get all active alerts and filter for emergency types
        final allAlertsResponse = await AlertsApi.getAllActiveAlerts();
        print('AlertsService: All alerts response: $allAlertsResponse');
        
        if (allAlertsResponse['success'] == true && allAlertsResponse['data'] != null) {
          final List<dynamic> allAlertsData = allAlertsResponse['data'];
          final allAlerts = allAlertsData.map((json) => Alert.fromJson(json)).toList();
          
          // Filter for emergency-related alerts
          final emergencyAlerts = allAlerts.where((alert) => alert.isEmergencyRelated).toList();
          
          print('AlertsService: Filtered ${emergencyAlerts.length} emergency alerts from ${allAlerts.length} total alerts');
          return emergencyAlerts;
        } else {
          print('AlertsService: No alerts found or API error: ${allAlertsResponse['message']}');
        }
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