import 'package:flutter/material.dart';

class IncidentQueueTab extends StatelessWidget {
  const IncidentQueueTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('Incident Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Live Updates', style: TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _IncidentFilterChip(label: 'All (5)', selected: true),
                  const SizedBox(width: 8),
                  _IncidentFilterChip(label: 'Pending (2)', selected: false),
                  const SizedBox(width: 8),
                  _IncidentFilterChip(label: 'Assigned (1)', selected: false),
                  const SizedBox(width: 8),
                  _IncidentFilterChip(label: 'Active (1)', selected: false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Incident Cards
            _IncidentCard(
              icon: Icons.medical_services,
              iconColor: Colors.red,
              title: 'Medical Emergency',
              status: 'pending',
              statusColor: Colors.red,
              description: 'Person collapsed in hallway, unconscious',
              location: 'Building A - Floor 3',
              timeAgo: '2 min ago',
              distance: '0.2 km',
              eta: '3 min',
              actionLabel: 'Accept',
              actionColor: Colors.green,
            ),
            _IncidentCard(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              title: 'Fire Alert',
              status: 'assigned',
              statusColor: Colors.blue,
              description: 'Smoke detected, possible kitchen fire',
              location: 'Building B - Kitchen',
              timeAgo: '5 min ago',
              distance: '0.5 km',
              eta: '4 min',
              actionLabel: 'Start Response',
              actionColor: Colors.blue,
            ),
            _IncidentCard(
              icon: Icons.security,
              iconColor: Colors.amber,
              title: 'Security Issue',
              status: 'pending',
              statusColor: Colors.red,
              description: 'Suspicious person loitering in parking area',
              location: 'Parking area',
              timeAgo: '',
              distance: '',
              eta: '',
              actionLabel: null,
              actionColor: null,
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {},
                    child: const Text('Emergency Call', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {},
                    child: const Text('Refresh Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _IncidentFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _IncidentFilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.red : Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final Color statusColor;
  final String description;
  final String location;
  final String timeAgo;
  final String distance;
  final String eta;
  final String? actionLabel;
  final Color? actionColor;

  const _IncidentCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.location,
    required this.timeAgo,
    required this.distance,
    required this.eta,
    this.actionLabel,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.15),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(color: Colors.black87, fontSize: 14)),
            const SizedBox(height: 2),
            Text(location, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (distance.isNotEmpty) ...[
                  Icon(Icons.location_on, color: Colors.grey, size: 16),
                  const SizedBox(width: 2),
                  Text(distance, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(width: 12),
                ],
                if (eta.isNotEmpty) ...[
                  Icon(Icons.timer, color: Colors.grey, size: 16),
                  const SizedBox(width: 2),
                  Text('ETA: $eta', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
                const Spacer(),
                if (actionLabel != null && actionColor != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    onPressed: () {},
                    child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black38),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 