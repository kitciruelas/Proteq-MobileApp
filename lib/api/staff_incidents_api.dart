import 'api_client.dart';
import 'package:flutter/foundation.dart';

class StaffIncidentsApi {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost/api'
      : 'http://192.168.100.134/api';
    
  /// Get incidents assigned to the current staff member
  static Future<Map<String, dynamic>> getAssignedIncidents({
    String? status,
    String? priorityLevel, 
    String? incidentType,
    String? resolvedToday,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (priorityLevel != null) queryParams['priority_level'] = priorityLevel;
      if (incidentType != null) queryParams['incident_type'] = incidentType;
      if (resolvedToday != null) queryParams['resolved_today'] = resolvedToday;

      final queryString = queryParams.isNotEmpty 
          ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
          : '';

      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffAssignedIncidents.php$queryString',
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

  /// Get all assigned incidents (for admin/overview or notifications)
  static Future<Map<String, dynamic>> getAllAssignedIncidents({
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
        endpoint: '/controller/StaffAllAssignedIncidents.php$queryString',
        method: 'GET',
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get all assigned incidents: $e',
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
    required int incidentId,
    required String validationStatus, // 'validated' or 'rejected'
    String? rejectionReason,
    String? validationNotes, // <-- Add this
  }) async {
    if (incidentId == null) {
      return {
        'success': false,
        'message': 'Incident ID is missing! Cannot validate incident.',
      };
    }
    try {
      final updateFields = <String, dynamic>{
        'validation_status': validationStatus,
      };
      if (rejectionReason != null) {
        updateFields['rejection_reason'] = rejectionReason;
      }
      if (validationNotes != null) {
        updateFields['validation_notes'] = validationNotes;
      }
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/IncidentUpdate.php',
        method: 'POST',
        body: {
          'incident_id': incidentId,
          'update_fields': updateFields,
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
    required int incidentId,
    String? status,
    String? priorityLevel,
    String? reporterSafeStatus,
    String? notes,
  }) async {
    if (incidentId == null) {
      return {
        'success': false,
        'message': 'Incident ID is missing! Cannot update incident.',
      };
    }
    try {
      final updateFields = <String, dynamic>{};
      if (status != null) updateFields['status'] = status;
      if (priorityLevel != null) updateFields['priority_level'] = priorityLevel;
      if (reporterSafeStatus != null) updateFields['reporter_safe_status'] = reporterSafeStatus;
      if (notes != null) updateFields['notes'] = notes;
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/IncidentUpdate.php',
        method: 'POST',
        body: {
          'incident_id': incidentId,
          'update_fields': updateFields,
        },
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
    required int incidentId,
  }) async {
    if (incidentId == null) {
      return {
        'success': false,
        'message': 'Incident ID is missing! Cannot accept incident.',
      };
    }
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=accept',
        method: 'POST',
        body: {
          'incident_id': incidentId,
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
    required int incidentId,
    String? estimatedArrivalTime,
  }) async {
    if (incidentId == null) {
      return {
        'success': false,
        'message': 'Incident ID is missing! Cannot start response.',
      };
    }
    try {
      final body = <String, dynamic>{
        'incident_id': incidentId,
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
    required int incidentId,
  }) async {
    if (incidentId == null) {
      return {
        'success': false,
        'message': 'Incident ID is missing! Cannot get incident details.',
      };
    }
    try {
      final response = await ApiClient.authenticatedCall(
        endpoint: '/controller/StaffIncidents.php?action=details&incident_id=$incidentId',
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