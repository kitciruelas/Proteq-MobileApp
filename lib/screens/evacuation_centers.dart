import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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

  final List<Map<String, dynamic>> centers = const [
    {
      'name': 'BSU Gymnasium',
      'capacity': '150/500',
      'contact': '09123456789',
      'status': 'open',
      'lat': 13.9401,
      'lng': 121.1636,
    },
    {
      'name': 'Municipal Covered Court',
      'capacity': '100/350',
      'contact': '09981234567',
      'status': 'open',
      'lat': 13.9405,
      'lng': 121.1620,
    },
    {
      'name': 'Elementary School Grounds',
      'capacity': '0/300',
      'contact': '09097654321',
      'status': 'open',
      'lat': 13.9410,
      'lng': 121.1640,
    },
    {
      'name': 'Batangas Coliseum',
      'capacity': '12/200',
      'contact': '091212121212',
      'status': 'open',
      'lat': 13.9420,
      'lng': 121.1650,
    },
  ];

  List<Map<String, dynamic>> get filteredCenters {
    if (_searchQuery.isEmpty) return centers;
    return centers.where((center) =>
      center['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      center['status'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
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
                initialCenter: LatLng(13.9401, 121.1636),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: centers.map((center) {
                    return Marker(
                      width: 40.0,
                      height: 40.0,
                      point: LatLng(center['lat'], center['lng']),
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
            // Drag handle
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
            // Search bar
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
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            // Centers list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCenters.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No centers found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredCenters.length,
                        itemBuilder: (context, index) {
                          final center = filteredCenters[index];
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
                                            center['name'],
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
                                            center['status'],
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
                                          'Capacity: ${center['capacity']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.phone, size: 16, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Text(
                                          center['contact'],
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