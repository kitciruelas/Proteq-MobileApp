import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../models/evacuation_center.dart';
import '../services/evacuation_center_service.dart';
import '../models/alert.dart';
import '../services/alerts_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/alerts_screen.dart'; // Added import for AlertsScreen
import '../api/alerts_api.dart';

class EvacuationCentersScreen extends StatefulWidget {
  const EvacuationCentersScreen({super.key});

  @override
  State<EvacuationCentersScreen> createState() => _EvacuationCentersScreenState();
}

class _EvacuationCentersScreenState extends State<EvacuationCentersScreen> {
  final MapController _mapController = MapController();
  final PanelController _panelController = PanelController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  List<EvacuationCenter> _centers = [];
  List<EvacuationCenter> _filteredCenters = [];
  EvacuationCenter? _selectedCenter;
  EvacuationCenter? _nearestCenter;
  bool _isFindingNearest = false;
  LatLng? _userLocation;
  
  // Emergency alerts state
  List<Alert> _emergencyAlerts = [];
  bool _isLoadingAlerts = true;
  bool _showAlertsPanel = false;
  List<Alert> _alerts = [];

  String _activePanel = 'alerts'; // 'alerts' or 'nearest'

  @override
  void initState() {
    super.initState();
    _fetchCenters();
    _fetchAlerts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredCenters = _filterCenters(_searchQuery);
    });
  }

  List<EvacuationCenter> _filterCenters(String query) {
    if (query.isEmpty) return _centers;
    return _centers.where((center) =>
      center.name.toLowerCase().contains(query.toLowerCase()) ||
      center.status.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Helper to calculate distance from user to center
  double? _distanceFromUser(EvacuationCenter center) {
    if (_userLocation == null) return null;
    final Distance distance = const Distance();
    return distance(
      _userLocation!,
      LatLng(center.lat, center.lng),
    ) / 1000; // Convert meters to kilometers
  }

  Future<void> _fetchCenters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final centers = await EvacuationCenterService.getAllCenters();
      // Debug print to check fetched data
      print('Fetched centers: \\${centers.length}');
      for (var c in centers) {
        print('Center: \\${c.name} (lat: \\${c.lat}, lng: \\${c.lng})');
      }
      print(centers); // Add this in your service after fetching from API
      setState(() {
        _centers = centers;
        _filteredCenters = _filterCenters(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load evacuation centers.';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _fetchCenters();
  }

  Future<void> _findNearestCenter() async {
    setState(() {
      _isFindingNearest = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _isFindingNearest = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _isFindingNearest = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _isFindingNearest = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      final nearest = await EvacuationCenterService.getNearestCenter(position.latitude, position.longitude);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      if (nearest != null) {
        setState(() {
          _nearestCenter = nearest;
          _selectedCenter = nearest;
        });
        _mapController.move(LatLng(nearest.lat, nearest.lng), _mapController.camera.zoom);
        _panelController.open();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nearest center: \'${nearest.name}\'')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No evacuation centers found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding nearest center: $e')),
      );
    } finally {
      setState(() {
        _isFindingNearest = false;
      });
    }
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoadingAlerts = true;
    });
    try {
      final response = await AlertsApi.getLatestActiveAlert();
      if (response['alert'] != null) {
        final alert = Alert.fromJson(response['alert']);
        print('Fetched alert: \\${alert.toJson()}'); // Debug print
        if (alert.isActive) {
          setState(() {
            _alerts = [alert];
          });
          if (alert.latitude != null && alert.longitude != null) {
            _mapController.move(
              LatLng(alert.latitude!, alert.longitude!),
              14.0, // preferred zoom
            );
          }
        } else {
          setState(() {
            _alerts = [];
          });
        }
      } else {
        setState(() {
          _alerts = [];
        });
      }
    } catch (e) {
      setState(() {
        _alerts = [];
      });
    } finally {
      setState(() {
        _isLoadingAlerts = false;
      });
    }
  }

  // Helper to get alert color based on type and priority
  Color _getAlertCardColor(String alertType, String priority) {
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

  IconData _getAlertIcon(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'emergency':
        return Icons.warning_amber_rounded;
      case 'drill':
        return Icons.directions_run_rounded;
      case 'earthquake':
        return Icons.waves_rounded;
      case 'typhoon':
        return Icons.cloud;
      case 'flood':
        return Icons.water_damage_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCenters,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    // Sort filtered centers so nearest is first if found
    List<EvacuationCenter> sortedCenters = List.from(_filteredCenters);
    if (_nearestCenter != null) {
      sortedCenters.removeWhere((c) => c.centerId == _nearestCenter!.centerId);
      sortedCenters.insert(0, _nearestCenter!);
    }
    return Scaffold(
      body: Stack(
        children: [
          if (_alerts.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    final alert = _alerts.first;
                    if (alert.latitude != null && alert.longitude != null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                Text('Type: ${alert.alertType}'),
                                Text('Priority: ${alert.priority}'),
                                if (alert.latitude != null && alert.longitude != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: SizedBox(
                                      width: 300,
                                      height: 200,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: FlutterMap(
                                          options: MapOptions(
                                            initialCenter: LatLng(alert.latitude!, alert.longitude!),
                                            initialZoom: 14.0,
                                            interactionOptions: const InteractionOptions(
                                              flags: InteractiveFlag.none,
                                            ),
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                                              subdomains: const ['a', 'b', 'c', 'd'],
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  point: LatLng(alert.latitude!, alert.longitude!),
                                                  width: 48,
                                                  height: 48,
                                                  child: Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.red.shade700,
                                                    size: 40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (alert.radiusKm != null)
                                              CircleLayer(
                                                circles: [
                                                  CircleMarker(
                                                    point: LatLng(alert.latitude!, alert.longitude!),
                                                    color: Colors.red.withOpacity(0.2),
                                                    borderStrokeWidth: 2,
                                                    borderColor: Colors.red,
                                                    radius: (alert.radiusKm! * 1000),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (alert.latitude != null && alert.longitude != null)
                                  Text('Location: ${alert.latitude}, ${alert.longitude}'),
                                if (alert.radiusKm != null)
                                  Text('Radius (km): ${alert.radiusKm}'),
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
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _getAlertCardColor(_alerts.first.alertType, _alerts.first.priority).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getAlertCardColor(_alerts.first.alertType, _alerts.first.priority).withOpacity(0.18),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getAlertCardColor(_alerts.first.alertType, _alerts.first.priority).withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Icon(
                            _getAlertIcon(_alerts.first.alertType),
                            color: _getAlertCardColor(_alerts.first.alertType, _alerts.first.priority),
                            size: 54,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getAlertCardColor(_alerts.first.alertType, _alerts.first.priority).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _alerts.first.priority.toUpperCase(),
                                      style: TextStyle(
                                        color: _getAlertCardColor(_alerts.first.alertType, _alerts.first.priority),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _alerts.first.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: _getAlertCardColor(_alerts.first.alertType, _alerts.first.priority),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (_alerts.first.message.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _alerts.first.message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 28),
                          onPressed: () {
                            setState(() {
                              _alerts.removeAt(0);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(13.9401, 121.1636),
              initialZoom: 13.0,
              onTap: (_, __) {
                setState(() {
                  _selectedCenter = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              // Active alert marker and circle
              if (_alerts.isNotEmpty && _alerts.first.latitude != null && _alerts.first.longitude != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_alerts.first.latitude!, _alerts.first.longitude!),
                      width: 60,
                      height: 60,
                      child: Tooltip(
                        message: _alerts.first.title,
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                          size: 54,
                        ),
                      ),
                    ),
                  ],
                ),
              if (_alerts.isNotEmpty && _alerts.first.latitude != null && _alerts.first.longitude != null && _alerts.first.radiusKm != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(_alerts.first.latitude!, _alerts.first.longitude!),
                      color: Colors.red.withOpacity(0.2),
                      borderStrokeWidth: 2,
                      borderColor: Colors.red,
                      radius: (_alerts.first.radiusKm! * 1000), // radius in meters
                    ),
                  ],
                ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 48,
                      height: 48,
                      child: Tooltip(
                        message: 'Your Location',
                        child: Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _filteredCenters.map((center) => Marker(
                  point: LatLng(center.lat, center.lng),
                  width: _selectedCenter == center ? 48 : 40,
                  height: _selectedCenter == center ? 48 : 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCenter = center;
                      });
                    },
                    child: Tooltip(
                      message: center.name,
                      child: Icon(
                        Icons.location_on,
                        color: _nearestCenter != null && center.centerId == _nearestCenter!.centerId
                            ? Colors.green
                            : (_selectedCenter == center ? Colors.blueAccent : Colors.red),
                        size: _selectedCenter == center ? 48 : 40,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              if (_selectedCenter != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_selectedCenter!.lat, _selectedCenter!.lng),
                      width: 200,
                      height: 100,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 180, maxWidth: 220),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedCenter!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 80,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            panel: Column(
              children: [
                // Drag handle for better UX
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (_activePanel == 'nearest' && _nearestCenter != null) ...[
                  // _buildNearestCenterCard(_nearestCenter!),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search evacuation centers...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: sortedCenters.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text('No evacuation centers found.', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: sortedCenters.length,
                          itemBuilder: (context, index) {
                            final center = sortedCenters[index];
                            final isNearest = _nearestCenter != null && center.centerId == _nearestCenter!.centerId;
                            final statusColor = center.status.toLowerCase() == 'open' ? Colors.green : Colors.red;
                            final distance = _distanceFromUser(center);
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              color: isNearest ? Colors.green.shade50 : null,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            center.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.place, size: 16, color: Colors.black54),
                                              const SizedBox(width: 4),
                                              Text(
                                                distance != null ? distance.toStringAsFixed(1) + ' km' : '',
                                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            center.status,
                                            style: const TextStyle(color: Colors.white, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.people, size: 18, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'Capacity: ',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                              ),
                                              TextSpan(
                                                text: ' ${center.currentOccupancy.toString().padLeft(2, '0')}/${center.capacity.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: center.currentOccupancy >= center.capacity
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Occupancy Rate',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${((center.currentOccupancy / center.capacity) * 100).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: center.currentOccupancy >= center.capacity
                                                    ? Colors.red
                                                    : (center.currentOccupancy / center.capacity) > 0.8
                                                        ? Colors.orange
                                                        : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: center.capacity > 0 ? center.currentOccupancy / center.capacity : 0,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            center.currentOccupancy >= center.capacity
                                                ? Colors.red
                                                : (center.currentOccupancy / center.capacity) > 0.8
                                                    ? Colors.orange
                                                    : Colors.green,
                                          ),
                                          minHeight: 8,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 18, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Text(center.contactNumber, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Tooltip(
                                          message: 'Get directions',
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              final url = 'https://www.google.com/maps/dir/?api=1&destination=${center.lat},${center.lng}&travelmode=driving';
                                              final uri = Uri.parse(url);
                                              try {
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                } else {
                                                  if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Could not launch navigation.')),
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error launching navigation: $e')),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.directions, size: 18),
                                            label: const Text('Directions'),
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              side: const BorderSide(color: Colors.blue),
                                              foregroundColor: Colors.blue,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Tooltip(
              message: 'Find the nearest evacuation center',
              child: FloatingActionButton.extended(
                heroTag: 'findNearest',
                onPressed: _isFindingNearest ? null : () async {
                  await _findNearestCenter();
                  setState(() {
                    _activePanel = 'nearest';
                  });
                  _panelController.open();
                },
                label: _isFindingNearest
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Find Nearest'),
                icon: const Icon(Icons.my_location),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 