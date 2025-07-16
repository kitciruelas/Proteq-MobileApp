import 'package:flutter/material.dart';
import '../models/assigned_incident.dart';
import 'incident_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final List<AssignedIncident>? incidents;
  const NotificationsScreen({Key? key, this.incidents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use provided incidents or mock data
    final List<AssignedIncident> notifications = incidents ?? [
      AssignedIncident(
        reportId: 1,
        userId: 101,
        incidentType: 'Medical',
        description: 'Medical emergency at Building A, 2nd floor.',
        location: 'Building A, 2nd floor',
        longitude: 120.9842,
        latitude: 14.5995,
        priorityLevel: 'critical',
        safetyStatus: 'unsafe',
        status: 'assigned',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
        reporterName: 'John Doe',
        reporterEmail: 'john.doe@email.com',
        validationStatus: 'unvalidated',
        reporterSafeStatus: 'unknown',
      ),
      AssignedIncident(
        reportId: 2,
        userId: 102,
        incidentType: 'Fire',
        description: 'Fire reported in Building B.',
        location: 'Building B',
        longitude: 120.9850,
        latitude: 14.6000,
        priorityLevel: 'high',
        safetyStatus: 'unsafe',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        reporterName: 'Jane Smith',
        reporterEmail: 'jane.smith@email.com',
        validationStatus: 'validated',
        reporterSafeStatus: 'safe',
      ),
      AssignedIncident(
        reportId: 3,
        userId: 103,
        incidentType: 'Security',
        description: 'Suspicious activity near Gate 3.',
        location: 'Gate 3',
        longitude: 120.9860,
        latitude: 14.6010,
        priorityLevel: 'moderate',
        safetyStatus: 'safe',
        status: 'resolved',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        reporterName: 'Security Bot',
        reporterEmail: 'bot@security.com',
        validationStatus: 'validated',
        reporterSafeStatus: 'safe',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final incident = notifications[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: incident.priorityColor.withOpacity(0.15),
                child: Icon(Icons.warning_amber_rounded, color: incident.priorityColor),
              ),
              title: Text(incident.incidentType, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(incident.description),
              trailing: Text(incident.timeSinceCreation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => IncidentDetailsScreen(incident: incident),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 