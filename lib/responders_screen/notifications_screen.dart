import 'package:flutter/material.dart';
import '../models/assigned_incident.dart';
import 'incident_details_screen.dart';
import '../api/staff_incidents_api.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  Future<List<AssignedIncident>> _fetchAllAssignedIncidents() async {
    final response = await StaffIncidentsApi.getAllAssignedIncidents();
    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => AssignedIncident.fromJson(e))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load incidents');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Fetch Assigned',
            onPressed: () async {
              final response = await StaffIncidentsApi.getAssignedIncidents();
              debugPrint('Assigned incidents: ' + response.toString());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fetched assigned incidents. Check debug console.')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AssignedIncident>>(
        future: _fetchAllAssignedIncidents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('NotificationsScreen error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }
          // Sort notifications from newest to oldest, handling nullable String createdAt
          final notifications = snapshot.data!..sort((a, b) {
            final aDate = a.createdAt != null ? DateTime.parse(a.createdAt!) : DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt != null ? DateTime.parse(b.createdAt!) : DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
          return ListView.separated(
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
          );
        },
      ),
    );
  }
} 