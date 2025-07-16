import '../api/staff_incidents_api.dart';
import '../models/assigned_incident.dart';

class StaffIncidentsService {
  /// Get incidents assigned to the current staff member
  static Future<Map<String, dynamic>> getAssignedIncidents({
    String? status,
    String? priorityLevel,
    String? incidentType,
  }) async {
    try {
      final result = await StaffIncidentsApi.getAssignedIncidents(
        status: status,
        priorityLevel: priorityLevel,
        incidentType: incidentType,
      );
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to view assigned incidents.',
          'requiresAuth': true,
        };
      }
      
      // Parse incidents if successful
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> incidentsData = result['data'];
        final List<AssignedIncident> incidents = incidentsData
            .map((json) => AssignedIncident.fromJson(json))
            .toList();
        
        return {
          'success': true,
          'data': incidents,
          'message': result['message'] ?? 'Incidents retrieved successfully',
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get assigned incidents: $e',
      };
    }
  }

  /// Update staff location
  static Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await StaffIncidentsApi.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to update location.',
          'requiresAuth': true,
        };
      }
      
      return result;
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
    required String validationStatus,
    String? rejectionReason,
  }) async {
    try {
      final result = await StaffIncidentsApi.validateIncident(
        reportId: reportId,
        validationStatus: validationStatus,
        rejectionReason: rejectionReason,
      );
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to validate incidents.',
          'requiresAuth': true,
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to validate incident: $e',
      };
    }
  }

  /// Update incident details
  static Future<Map<String, dynamic>> updateIncident({
    required int reportId,
    String? status,
    String? priorityLevel,
    String? reporterSafeStatus,
    String? notes,
  }) async {
    try {
      final result = await StaffIncidentsApi.updateIncident(
        reportId: reportId,
        status: status,
        priorityLevel: priorityLevel,
        reporterSafeStatus: reporterSafeStatus,
        notes: notes,
      );
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to update incidents.',
          'requiresAuth': true,
        };
      }
      
      return result;
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
      final result = await StaffIncidentsApi.acceptIncident(
        reportId: reportId,
      );
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to accept incidents.',
          'requiresAuth': true,
        };
      }
      
      return result;
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
      final result = await StaffIncidentsApi.startResponse(
        reportId: reportId,
        estimatedArrivalTime: estimatedArrivalTime,
      );
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to start responses.',
          'requiresAuth': true,
        };
      }
      
      return result;
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
      final result = await StaffIncidentsApi.getIncidentDetails(
        reportId: reportId,
      );
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to view incident details.',
          'requiresAuth': true,
        };
      }
      
      // Parse incident if successful
      if (result['success'] == true && result['data'] != null) {
        final incident = AssignedIncident.fromJson(result['data']);
        return {
          'success': true,
          'data': incident,
          'message': result['message'] ?? 'Incident details retrieved successfully',
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get incident details: $e',
      };
    }
  }

  /// Filter incidents by status
  static List<AssignedIncident> filterIncidentsByStatus(List<AssignedIncident> incidents, String status) {
    return incidents.where((incident) => incident.status.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Filter incidents by priority
  static List<AssignedIncident> filterIncidentsByPriority(List<AssignedIncident> incidents, String priority) {
    return incidents.where((incident) => incident.priorityLevel.toLowerCase() == priority.toLowerCase()).toList();
  }

  /// Filter incidents by validation status
  static List<AssignedIncident> filterIncidentsByValidationStatus(List<AssignedIncident> incidents, String validationStatus) {
    return incidents.where((incident) => incident.validationStatus.toLowerCase() == validationStatus.toLowerCase()).toList();
  }

  /// Get urgent incidents (Critical priority or In Danger safety status)
  static List<AssignedIncident> getUrgentIncidents(List<AssignedIncident> incidents) {
    return incidents.where((incident) => 
      incident.priorityLevel.toLowerCase() == 'critical' || 
      incident.safetyStatus.toLowerCase() == 'in danger'
    ).toList();
  }

  /// Get incidents that need validation
  static List<AssignedIncident> getIncidentsNeedingValidation(List<AssignedIncident> incidents) {
    return incidents.where((incident) => incident.validationStatus.toLowerCase() == 'unvalidated').toList();
  }

  /// Sort incidents by priority and distance
  static List<AssignedIncident> sortIncidentsByPriorityAndDistance(List<AssignedIncident> incidents) {
    final sorted = List<AssignedIncident>.from(incidents);
    
    sorted.sort((a, b) {
      // First sort by priority
      final priorityOrder = {'critical': 0, 'high': 1, 'moderate': 2, 'low': 3};
      final aPriority = priorityOrder[a.priorityLevel.toLowerCase()] ?? 4;
      final bPriority = priorityOrder[b.priorityLevel.toLowerCase()] ?? 4;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      // Then sort by distance (closer first)
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      
      // If one has distance and other doesn't, prioritize the one with distance
      if (a.distance != null) return -1;
      if (b.distance != null) return 1;
      
      // Finally sort by creation time (newer first)
      if (a.createdAt != null && b.createdAt != null) {
        return DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!));
      }
      
      return 0;
    });
    
    return sorted;
  }

  /// Get response statistics
  static Map<String, dynamic> getResponseStatistics(List<AssignedIncident> incidents) {
    final activeIncidents = incidents.where((i) => 
      ['assigned', 'en route', 'on scene', 'in_progress'].contains(i.status.toLowerCase())
    ).length;
    
    final resolvedToday = incidents.where((i) {
      if (i.status.toLowerCase() != 'resolved' || i.updatedAt == null) return false;
      try {
        final resolvedDate = DateTime.parse(i.updatedAt!);
        final today = DateTime.now();
        return resolvedDate.year == today.year && 
               resolvedDate.month == today.month && 
               resolvedDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
    
    final criticalIncidents = incidents.where((i) => 
      i.priorityLevel.toLowerCase() == 'critical'
    ).length;
    
    final nearbyIncidents = incidents.where((i) => 
      i.distance != null && i.distance! < 1.0 // Within 1km
    ).length;

    final unvalidatedIncidents = incidents.where((i) => 
      i.validationStatus.toLowerCase() == 'unvalidated'
    ).length;
    
    return {
      'activeIncidents': activeIncidents,
      'resolvedToday': resolvedToday,
      'criticalIncidents': criticalIncidents,
      'nearbyIncidents': nearbyIncidents,
      'unvalidatedIncidents': unvalidatedIncidents,
    };
  }
} 