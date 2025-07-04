import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../models/evacuation_center.dart';
import '../services/evacuation_center_service.dart';

class EvacuationCentersScreen extends StatefulWidget {
  const EvacuationCentersScreen({super.key});

  @override
  State<EvacuationCentersScreen> createState() => _EvacuationCentersScreenState();
}

class _EvacuationCentersScreenState extends State<EvacuationCentersScreen> {
  final PanelController _panelController = PanelController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  List<EvacuationCenter> _centers = [];
  List<EvacuationCenter> _filteredCenters = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _centers.isNotEmpty
                  ? LatLng(_centers[0].lat, _centers[0].lng)
                  : LatLng(13.9401, 121.1636),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _centers
                      .where((center) => center.lat != 0.0 && center.lng != 0.0)
                      .map((center) {
                    return Marker(
                      width: 40.0,
                      height: 40.0,
                      point: LatLng(center.lat, center.lng),
                      child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    );
                  }).toList(),
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.location_searching, size: 20),
                    label: const Text('Find Nearest', style: TextStyle(fontSize: 12)),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.list, color: Colors.black87),
                    onPressed: () => _panelController.isPanelOpen 
                      ? _panelController.close() 
                      : _panelController.open(),
                  ),
                ],
              ),
            ),
          ],
        ),
        panel: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search centers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    : _filteredCenters.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _centers.isEmpty
                                    ? 'No evacuation centers available.'
                                    : 'No centers match your search.',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredCenters.length,
                          itemBuilder: (context, index) {
                            final center = _filteredCenters[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // TODO: Implement center selection
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.apartment, color: Colors.blue[800], size: 24),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              center.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              center.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.people, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Capacity: ${center.capacity}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.phone, size: 16, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            center.contact,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.directions),
                                            label: const Text('Directions'),
                                            onPressed: () {
                                              // TODO: Implement directions
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              // TODO: Implement view details
                                            },
                                            child: const Text('View Details'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 