import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proteq_mobileapp/models/assigned_incident.dart';
import 'package:proteq_mobileapp/services/staff_incidents_service.dart';

void main() {
  group('StaffIncidentsService Tests', () {
    test('should filter incidents by status', () {
      final incidents = [
        AssignedIncident(
          userId: 1,
          incidentType: 'Medical Emergency',
          description: 'Test incident 1',
          location: 'Building A',
          priorityLevel: 'High',
          safetyStatus: 'Safe',
          status: 'Assigned',
        ),
        AssignedIncident(
          userId: 2,
          incidentType: 'Fire Alert',
          description: 'Test incident 2',
          location: 'Building B',
          priorityLevel: 'Critical',
          safetyStatus: 'In Danger',
          status: 'En Route',
        ),
      ];

      final assignedIncidents = StaffIncidentsService.filterIncidentsByStatus(incidents, 'Assigned');
      expect(assignedIncidents.length, 1);
      expect(assignedIncidents.first.status, 'Assigned');
    });

    test('should filter incidents by priority', () {
      final incidents = [
        AssignedIncident(
          userId: 1,
          incidentType: 'Medical Emergency',
          description: 'Test incident 1',
          location: 'Building A',
          priorityLevel: 'High',
          safetyStatus: 'Safe',
          status: 'Assigned',
        ),
        AssignedIncident(
          userId: 2,
          incidentType: 'Fire Alert',
          description: 'Test incident 2',
          location: 'Building B',
          priorityLevel: 'Critical',
          safetyStatus: 'In Danger',
          status: 'En Route',
        ),
      ];

      final criticalIncidents = StaffIncidentsService.filterIncidentsByPriority(incidents, 'Critical');
      expect(criticalIncidents.length, 1);
      expect(criticalIncidents.first.priorityLevel, 'Critical');
    });

    test('should get urgent incidents', () {
      final incidents = [
        AssignedIncident(
          userId: 1,
          incidentType: 'Medical Emergency',
          description: 'Test incident 1',
          location: 'Building A',
          priorityLevel: 'High',
          safetyStatus: 'Safe',
          status: 'Assigned',
        ),
        AssignedIncident(
          userId: 2,
          incidentType: 'Fire Alert',
          description: 'Test incident 2',
          location: 'Building B',
          priorityLevel: 'Critical',
          safetyStatus: 'In Danger',
          status: 'En Route',
        ),
      ];

      final urgentIncidents = StaffIncidentsService.getUrgentIncidents(incidents);
      expect(urgentIncidents.length, 2); // Both critical priority and in danger
    });

    test('should sort incidents by priority and distance', () {
      final incidents = [
        AssignedIncident(
          userId: 1,
          incidentType: 'Medical Emergency',
          description: 'Test incident 1',
          location: 'Building A',
          priorityLevel: 'High',
          safetyStatus: 'Safe',
          status: 'Assigned',
          distance: 0.5,
        ),
        AssignedIncident(
          userId: 2,
          incidentType: 'Fire Alert',
          description: 'Test incident 2',
          location: 'Building B',
          priorityLevel: 'Critical',
          safetyStatus: 'In Danger',
          status: 'En Route',
          distance: 0.3,
        ),
      ];

      final sortedIncidents = StaffIncidentsService.sortIncidentsByPriorityAndDistance(incidents);
      expect(sortedIncidents.first.priorityLevel, 'Critical'); // Critical should come first
      expect(sortedIncidents.first.distance, 0.3); // Closer distance should come first within same priority
    });

    test('should get response statistics', () {
      final incidents = [
        AssignedIncident(
          userId: 1,
          incidentType: 'Medical Emergency',
          description: 'Test incident 1',
          location: 'Building A',
          priorityLevel: 'High',
          safetyStatus: 'Safe',
          status: 'Assigned',
          distance: 0.5,
        ),
        AssignedIncident(
          userId: 2,
          incidentType: 'Fire Alert',
          description: 'Test incident 2',
          location: 'Building B',
          priorityLevel: 'Critical',
          safetyStatus: 'In Danger',
          status: 'En Route',
          distance: 0.3,
        ),
      ];

      final stats = StaffIncidentsService.getResponseStatistics(incidents);
      expect(stats['activeIncidents'], 2);
      expect(stats['criticalIncidents'], 1);
      expect(stats['nearbyIncidents'], 2);
    });
  });

  group('AssignedIncident Model Tests', () {
    test('should format distance correctly', () {
      final incident = AssignedIncident(
        userId: 1,
        incidentType: 'Test',
        description: 'Test',
        location: 'Test',
        priorityLevel: 'High',
        safetyStatus: 'Safe',
        distance: 0.5,
      );

      expect(incident.formattedDistance, '500m away');
    });

    test('should get priority color', () {
      final criticalIncident = AssignedIncident(
        userId: 1,
        incidentType: 'Test',
        description: 'Test',
        location: 'Test',
        priorityLevel: 'Critical',
        safetyStatus: 'Safe',
      );

      expect(criticalIncident.priorityColor, isA<Color>());
    });

    test('should get status color', () {
      final assignedIncident = AssignedIncident(
        userId: 1,
        incidentType: 'Test',
        description: 'Test',
        location: 'Test',
        priorityLevel: 'High',
        safetyStatus: 'Safe',
        status: 'Assigned',
      );

      expect(assignedIncident.statusColor, isA<Color>());
    });
  });
} 