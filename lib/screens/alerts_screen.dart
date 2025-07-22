import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../models/safety_protocol.dart';
import '../services/alerts_service.dart';
import '../services/safety_protocols_service.dart';
import 'package:geocoding/geocoding.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  late Future<List<Alert>> _alertsFuture;
  late Future<List<SafetyProtocol>> _protocolsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _alertsFuture = AlertsService.getActiveAlerts();
    _protocolsFuture = SafetyProtocolsService.getAllProtocols();
    _tabController = TabController(length: 2, vsync: this);
  }

  Color _getAlertColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getAlertCardColor(String alertType, String priority) {
    switch (alertType.toLowerCase()) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'emergency':
        return Colors.red;
      default:
        return _getAlertColor(priority);
    }
  }

  IconData _getAlertIcon(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'drill':
        return Icons.sports_soccer;
      case 'earthquake':
        return Icons.vibration;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_active;
    }
  }

  IconData _getProtocolIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'earthquake':
        return Icons.place;
      case 'medical':
        return Icons.medical_services;
      case 'intrusion':
        return Icons.security;
      case 'general':
        return Icons.verified_user;
      default:
        return Icons.info;
    }
  }

  Color _getProtocolColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'earthquake':
        return Colors.orange;
      case 'medical':
        return Colors.cyan;
      case 'intrusion':
        return Colors.purple;
      case 'general':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateShort(DateTime? date) {
    if (date == null) return '';
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  Future<String> getPlaceName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality?.isNotEmpty == true
            ? place.locality!
            : place.subAdministrativeArea?.isNotEmpty == true
                ? place.subAdministrativeArea!
                : place.administrativeArea?.isNotEmpty == true
                    ? place.administrativeArea!
                    : place.country ?? '';
      }
    } catch (e) {
      // ignore error, fallback to empty
    }
    return '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications & Protocols'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Alerts'),
            Tab(text: 'Safety Protocols'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Alerts Tab
          FutureBuilder<List<Alert>>(
            future: _alertsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Failed to load alerts.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No alerts at this time.'));
              }
              final alerts = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: Icon(_getAlertIcon(alert.alertType), color: _getAlertCardColor(alert.alertType, alert.priority)),
                      title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (alert.message.isNotEmpty)
                            Text(alert.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            alert.createdAt != null ? _formatDate(alert.createdAt) : '',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return FutureBuilder<String>(
                              future: alert.latitude != null && alert.longitude != null
                                  ? getPlaceName(alert.latitude!, alert.longitude!)
                                  : Future.value(''),
                              builder: (context, snapshot) {
                                String locationName = snapshot.data ?? '';
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(_getAlertIcon(alert.alertType), color: _getAlertCardColor(alert.alertType, alert.priority)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(alert.title)),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (alert.message.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text(alert.message),
                                        ),
                                      Text('Type: \t\t${alert.alertType}'),
                                      Text('Priority: ${alert.priority}'),
                                      Text('Date:    ${alert.createdAt != null ? _formatDate(alert.createdAt) : ''}'),
                                      if (alert.radiusKm != null)
                                        Text('Radius (km): ${alert.radiusKm}'),
                                      if (alert.latitude != null && alert.longitude != null)
                                        Text('Exact Location: '
                                          + (locationName.isNotEmpty ? locationName : '${alert.latitude}, ${alert.longitude}')
                                        ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          // Safety Protocols Tab
          FutureBuilder<List<SafetyProtocol>>(
            future: _protocolsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Failed to load safety protocols.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No safety protocols at this time.'));
              }
              final protocols = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: protocols.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final protocol = protocols[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: Icon(_getProtocolIcon(protocol.type), color: _getProtocolColor(protocol.type)),
                      title: Text(protocol.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(protocol.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            protocol.createdAt != null ? _formatDateShort(protocol.createdAt) : '',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
} 