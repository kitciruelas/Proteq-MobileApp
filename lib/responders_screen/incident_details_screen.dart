import 'package:flutter/material.dart';
import '../models/assigned_incident.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final AssignedIncident incident;
  const IncidentDetailsScreen({Key? key, required this.incident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Details'),
        backgroundColor: incident.priorityColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: incident.priorityColor.withOpacity(0.15),
                  child: Icon(Icons.warning_amber_rounded, color: incident.priorityColor, size: 28),
                  radius: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.incidentType,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: incident.priorityColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          incident.priorityLevel.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(incident.description, style: TextStyle(fontSize: 15)),
            const SizedBox(height: 18),
            _DetailRow(label: 'Location', value: incident.location, icon: Icons.location_on, color: Colors.red),
            if (incident.distance != null)
              _DetailRow(label: 'Distance', value: incident.formattedDistance, icon: Icons.straighten, color: Colors.green),
            _DetailRow(label: 'Status', value: incident.status, icon: Icons.info, color: incident.statusColor),
            _DetailRow(label: 'Priority', value: incident.priorityLevel, icon: Icons.priority_high, color: incident.priorityColor),
            _DetailRow(label: 'Safety Status', value: incident.safetyStatus, icon: Icons.health_and_safety, color: Colors.blue),
            _DetailRow(label: 'Validation', value: incident.validationStatus, icon: Icons.verified, color: incident.validationStatusColor),
            _DetailRow(label: 'Reporter Safe', value: incident.reporterSafeStatus, icon: Icons.person, color: incident.reporterSafeStatusColor),
            if (incident.createdAt != null)
              _DetailRow(label: 'Reported', value: incident.timeSinceCreation, icon: Icons.schedule, color: Colors.black54),
            if (incident.reporterName != null)
              _DetailRow(label: 'Reporter', value: incident.reporterName!, icon: Icons.person, color: Colors.black87),
            if (incident.reporterEmail != null)
              _DetailRow(label: 'Email', value: incident.reporterEmail!, icon: Icons.email, color: Colors.black87),
            if (incident.estimatedArrivalTime != null)
              _DetailRow(label: 'ETA', value: incident.estimatedArrivalTime!, icon: Icons.timer, color: Colors.orange),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _DetailRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
} 