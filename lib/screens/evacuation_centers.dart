import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../models/evacuation_center.dart';
import '../services/evacuation_center_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchCenters();
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
                            constraints: const BoxConstraints(maxHeight: 90, maxWidth: 180),
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
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedCenter!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Status: \\${_selectedCenter!.status}'),
                                  Text('Capacity: \\${_selectedCenter!.capacity}'),
                                  Text('Occupancy: \\${_selectedCenter!.currentOccupancy}'),
                                  Text('Contact: \\${_selectedCenter!.contactPerson}'),
                                  Text('Phone: \\${_selectedCenter!.contactNumber}'),
                                ],
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
                if (_selectedCenter != null)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedCenter!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.blue),
                                tooltip: 'Close details',
                                onPressed: () {
                                  setState(() {
                                    _selectedCenter = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.info, size: 18, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text('Status: \\${_selectedCenter!.status}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 4),
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
                                      text: ' \\${_selectedCenter!.currentOccupancy}/\\${_selectedCenter!.capacity}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _selectedCenter!.currentOccupancy >= _selectedCenter!.capacity
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text('Contact: \\${_selectedCenter!.contactPerson}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 18, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text('Phone: \\${_selectedCenter!.contactNumber}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ],
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
                                            style: isNearest
                                              ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)
                                              : const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                                                text: ' ${center.currentOccupancy}/${center.capacity}',
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
                                          message: 'View details on map',
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _selectedCenter = center;
                                              });
                                              _mapController.move(
                                                LatLng(center.lat, center.lng),
                                                _mapController.camera.zoom,
                                              );
                                            },
                                            icon: const Icon(Icons.info_outline, size: 18),
                                            label: const Text('View'),
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Tooltip(
                                          message: 'Get directions',
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              final url = Uri.encodeFull(
                                                'https://www.google.com/maps/dir/?api=1&destination=\\${center.lat},\\${center.lng}'
                                              );
                                              if (await canLaunchUrl(Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url));
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Could not open maps.'))
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
                onPressed: _isFindingNearest ? null : _findNearestCenter,
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