import 'package:flutter/material.dart';

class IncidentAssignedTab extends StatelessWidget {
  const IncidentAssignedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matched Incidents',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Incidents that match your location and expertise',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFFFFF6F6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: Text(
                          'Incident #4',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Tooltip(
                        message: 'Incident has been validated',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Validated',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Critical priority',
                        child: Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Critical',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: const [
                      Icon(Icons.local_hospital, color: Colors.red, size: 18),
                      SizedBox(width: 4),
                      Flexible(child: Text('Type: ', style: TextStyle(fontWeight: FontWeight.bold))),
                      Flexible(child: Text('Injury', overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.timelapse, color: Colors.blue, size: 18),
                      SizedBox(width: 4),
                      Flexible(child: Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold))),
                      Flexible(child: Text('In Progress', overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.person, color: Colors.green, size: 18),
                      SizedBox(width: 4),
                      Flexible(child: Text('Reporter Status: ', style: TextStyle(fontWeight: FontWeight.bold))),
                      Flexible(child: Text('Safe', overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Reported: 6/14/2025, 1:22:11 PM',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text(
                          'Update Status',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: const IncidentDetailsBottomSheet(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IncidentDetailsBottomSheet extends StatefulWidget {
  const IncidentDetailsBottomSheet({super.key});

  @override
  State<IncidentDetailsBottomSheet> createState() => _IncidentDetailsBottomSheetState();
}

class _IncidentDetailsBottomSheetState extends State<IncidentDetailsBottomSheet> {
  String reporterStatus = 'Safe';
  String validation = 'Validated';
  final TextEditingController notesController = TextEditingController();

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
                      child: const Text('Injury', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('tes test', overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.red, size: 18),
                        SizedBox(width: 4),
                        Flexible(child: Text('14.084478°N, 121.150113°E', overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const Text('Distance: 43.7km', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Flexible(child: Text('6/14/2025, 1:22:11 PM', overflow: TextOverflow.ellipsis)),
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