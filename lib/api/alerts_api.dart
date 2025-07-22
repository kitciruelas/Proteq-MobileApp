import '../models/alert.dart';
import 'api_client.dart';

class AlertsApi {
  // Get latest active alert
  static Future<Map<String, dynamic>> getLatestActiveAlert() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php',
      method: 'GET',
    );
  }

  // Get all active alerts
  static Future<Map<String, dynamic>> getAllActiveAlerts() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php/all',
      method: 'GET',
    );
  }

  // Get alert by ID
  static Future<Map<String, dynamic>> getAlertById(int alertId) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php/by-id?id=$alertId',
      method: 'GET',
    );
  }

  // Get alerts by type
  static Future<Map<String, dynamic>> getAlertsByType(String alertType) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php/by-type?type=$alertType',
      method: 'GET',
    );
  }

  // Get emergency alerts (high priority)
  static Future<Map<String, dynamic>> getEmergencyAlerts() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php/emergency',
      method: 'GET',
    );
  }

  // Get drill alerts
  static Future<Map<String, dynamic>> getDrillAlerts() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php/by-type?type=drill',
      method: 'GET',
    );
  }

  // Get info alerts
  static Future<Map<String, dynamic>> getInfoAlerts() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php/by-type?type=info',
      method: 'GET',
    );
  }

  // Get warning alerts
  static Future<Map<String, dynamic>> getWarningAlerts() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/Alerts.php/by-type?type=warning',
      method: 'GET',
    );
  }
} 