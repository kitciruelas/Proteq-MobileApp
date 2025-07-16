import 'api_client.dart';
import 'package:flutter/foundation.dart';

class StaffIncidentsApi {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api'
      : 'http://192.168.1.2/api';
    
  /// Get incidents assigned to the current staff member
  static Future<Map<String, dynamic>> getAssignedIncidents({
    String? status,
    String? priorityLevel,
    String? incidentType,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (priorityLevel != null) queryParams['priority_level'] = priorityLevel;
      if (incidentType != null) queryParams['incident_type'] = incidentType;

      final queryString = queryParams.isNotEmpty 
          ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
          : '';

      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php$queryString',
        method: 'GET',
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get assigned incidents: $e',
      };
    }
  }

  /// Update staff location for distance calculations
  static Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=location',
        method: 'POST',
        body: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update location: $e',
      };
    }
  }

  /// Validate an incident report
  static Future<Map<String, dynamic>> validateIncident({
    required int reportId,
    required String validationStatus, // 'validated' or 'rejected'
    String? rejectionReason,
  }) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=validate',
        method: 'POST',
        body: {
          'report_id': reportId,
          'validation_status': validationStatus,
          if (rejectionReason != null) 'rejection_reason': rejectionReason,
        },
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to validate incident: $e',
      };
    }
  }

  /// Update incident details (status, priority, reporter safe status)
  static Future<Map<String, dynamic>> updateIncident({
    required int reportId,
    String? status,
    String? priorityLevel,
    String? reporterSafeStatus,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'report_id': reportId,
      };
      
      if (status != null) body['status'] = status;
      if (priorityLevel != null) body['priority_level'] = priorityLevel;
      if (reporterSafeStatus != null) body['reporter_safe_status'] = reporterSafeStatus;
      if (notes != null) body['notes'] = notes;

      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=update',
        method: 'POST',
        body: body,
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update incident: $e',
      };
    }
  }

  /// Accept an incident assignment
  static Future<Map<String, dynamic>> acceptIncident({
    required int reportId,
  }) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=accept',
        method: 'POST',
        body: {
          'report_id': reportId,
        },
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to accept incident: $e',
      };
    }
  }

  /// Start response to an incident
  static Future<Map<String, dynamic>> startResponse({
    required int reportId,
    String? estimatedArrivalTime,
  }) async {
    try {
      final body = <String, dynamic>{
        'report_id': reportId,
      };
      
      if (estimatedArrivalTime != null) body['estimated_arrival_time'] = estimatedArrivalTime;

      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=start_response',
        method: 'POST',
        body: body,
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to start response: $e',
      };
    }
  }

  /// Get incident details for editing
  static Future<Map<String, dynamic>> getIncidentDetails({
    required int reportId,
  }) async {
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=details&report_id=$reportId',
        method: 'GET',
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get incident details: $e',
      };
    }
  }
} 