import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class IncidentsMapTab extends StatelessWidget {
  const IncidentsMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample incident data
    final List<Map<String, dynamic>> incidents = [
      {
        'title': 'Fire Alarm',
        'lat': 13.9401,
        'lng': 121.1636,
        'color': Colors.red,
        'type': 'Injury',
        'description': 'Fire alarm triggered in Building A',
        'location': '14.084478°N, 121.150113°E',
        'distance': '43.7km',
        'time': '6/14/2025, 1:22:11 PM',
        'priority': 'Critical',
        'status': 'In Progress',
        'validation': 'Validated',
        'notes': '',
        'reporterStatus': 'Unknown',
      },
      {
        'title': 'Medical Emergency',
        'lat': 13.9410,
        'lng': 121.1640,
        'color': Colors.orange,
        'type': 'Medical',
        'description': 'Person fainted in cafeteria',
        'location': '14.084478°N, 121.150113°E',
        'distance': '12.3km',
        'time': '6/14/2025, 2:10:00 PM',
        'priority': 'Critical',
        'status': 'In Progress',
        'validation': 'Pending',
        'notes': '',
        'reporterStatus': 'Unknown',
      },
      {
        'title': 'Power Outage',
        'lat': 13.9420,
        'lng': 121.1650,
        'color': Colors.green,
        'type': 'Utility',
        'description': 'Power outage in Block C',
        'location': '14.084478°N, 121.150113°E',
        'distance': '5.1km',
        'time': '6/14/2025, 3:00:00 PM',
        'priority': 'Normal',
        'status': 'Resolved',
        'validation': 'Validated',
        'notes': '',
        'reporterStatus': 'Safe',
      },
      {
        'title': 'Security Alert',
        'lat': 13.9405,
        'lng': 121.1620,
        'color': Colors.red,
        'type': 'Security',
        'description': 'Unauthorized access detected',
        'location': '14.084478°N, 121.150113°E',
        'distance': '8.7km',
        'time': '6/14/2025, 4:15:00 PM',
        'priority': 'Critical',
        'status': 'In Progress',
        'validation': 'Rejected',
        'notes': '',
        'reporterStatus': 'Unsafe',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(13.9401, 121.1636),
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: incidents.map((incident) {
                return Marker(
                  width: 80.0,
                  height: 60.0,
                  point: LatLng(incident['lat'], incident['lng']),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => IncidentDetailsSheet(incident: incident),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: incident['title'],
                          child: Icon(
                            Icons.location_on,
                            color: incident['color'],
                            size: 36,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            incident['title'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class IncidentDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> incident;
  const IncidentDetailsSheet({super.key, required this.incident});

  @override
  State<IncidentDetailsSheet> createState() => _IncidentDetailsSheetState();
}

class _IncidentDetailsSheetState extends State<IncidentDetailsSheet> {
  late String validation;
  late String reporterStatus;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    validation = widget.incident['validation'] ?? 'Validated';
    reporterStatus = widget.incident['reporterStatus'] ?? 'Unknown';
    notesController = TextEditingController(text: widget.incident['notes'] ?? '');
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Incident Details',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Incident Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(widget.incident['type'] ?? 'Type', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.incident['description'] ?? '', overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Flexible(child: Text(widget.incident['location'] ?? '', overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    Text('Distance: ${widget.incident['distance']}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(child: Text(widget.incident['time'] ?? '', overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Status & Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Tooltip(
                              message: 'Critical priority',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Critical', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Tooltip(
                              message: 'Incident is in progress',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.cyan[600],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('In Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Validation', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: validation,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Validated', child: Text('Validated')),
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                      ],
                      onChanged: (val) {
                        setState(() => validation = val ?? 'Validated');
                      },
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Validation notes... (optional)',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Reporter Safety Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Safe'),
                      value: 'Safe',
                      groupValue: reporterStatus,
                      onChanged: (val) => setState(() => reporterStatus = val!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: const Text('Unsafe'),
                      value: 'Unsafe',
                      groupValue: reporterStatus,
                      onChanged: (val) => setState(() => reporterStatus = val!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: const Text('Unknown'),
                      value: 'Unknown',
                      groupValue: reporterStatus,
                      onChanged: (val) => setState(() => reporterStatus = val!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Tooltip(
                    message: 'Mark this incident as resolved',
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incident marked as resolved.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as Resolved', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 

