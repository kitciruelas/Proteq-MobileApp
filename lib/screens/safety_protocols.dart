import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/safety_protocol.dart';
import '../services/safety_protocols_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SafetyProtocolsScreen extends StatefulWidget {
  const SafetyProtocolsScreen({super.key});

  @override
  State<SafetyProtocolsScreen> createState() => _SafetyProtocolsScreenState();
}

class _SafetyProtocolsScreenState extends State<SafetyProtocolsScreen> {
  List<SafetyProtocol> protocols = [];
  List<SafetyProtocol> filteredProtocols = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  final List<_FilterChipData> filters = [
    _FilterChipData('All', Icons.apps, Colors.grey[700]!),
    _FilterChipData('Fire', Icons.local_fire_department, Colors.red),
    _FilterChipData('Earthquake', Icons.place, Colors.orange),
    _FilterChipData('Medical', Icons.medical_services, Colors.cyan),
    _FilterChipData('Intrusion', Icons.security, Colors.purple),
    _FilterChipData('General', Icons.verified_user, Colors.green),
  ];

  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final protocolsResult = await SafetyProtocolsService.getAllProtocols();
      setState(() {
        protocols = protocolsResult;
        isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  void _applyFilters() {
    filteredProtocols = SafetyProtocolsService.filterProtocolsByType(protocols, selectedFilter);
    filteredProtocols = SafetyProtocolsService.filterProtocolsBySearch(filteredProtocols, searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(10),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search protocols...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = '';
                                      _applyFilters();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filters.map((filter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(filter.icon, color: filter.color, size: 18),
                                  const SizedBox(width: 4),
                                  Text(filter.label, style: TextStyle(color: filter.color)),
                                ],
                              ),
                              selected: selectedFilter == filter.label,
                              selectedColor: filter.color.withOpacity(0.13),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: filter.color.withOpacity(0.5)),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  selectedFilter = filter.label;
                                  _applyFilters();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Loading and Error States
                    if (isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Column(
                            children: const [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                              SizedBox(height: 18),
                              Text('Loading protocols...', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    else if (hasError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage,
                                style: const TextStyle(fontSize: 16, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (filteredProtocols.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Column(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.grey, size: 48),
                              SizedBox(height: 12),
                              Text(
                                'No protocols found.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: filteredProtocols
                            .map((protocol) => _ProtocolCard(protocol: protocol))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipData {
  final String label;
  final IconData icon;
  final Color color;
  _FilterChipData(this.label, this.icon, this.color);
}

// Helper function to get icon data from protocol type
IconData _getIconFromType(String type) {
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

// Helper function to get color from protocol type
Color _getColorFromType(String type) {
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

class _ProtocolCard extends StatelessWidget {
  final SafetyProtocol protocol;
  const _ProtocolCard({required this.protocol});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _getColorFromType(protocol.type).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _getColorFromType(protocol.type).withOpacity(0.18), width: 1.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Type
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getColorFromType(protocol.type).withOpacity(0.13),
                  radius: 22,
                  child: Icon(_getIconFromType(protocol.type), color: _getColorFromType(protocol.type), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    protocol.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _getColorFromType(protocol.type)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorFromType(protocol.type).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    protocol.type,
                    style: TextStyle(
                      color: _getColorFromType(protocol.type),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              'Description',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              protocol.description,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
            const SizedBox(height: 16),
            // Attachment
            if (protocol.attachment != null && protocol.attachment!.isNotEmpty) ...[
              Text(
                'Attachment',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file, color: Colors.white),
                label: const Text('View Attachment', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColorFromType(protocol.type),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () async {
                  final url = protocol.attachment!;
                  try {
                    final dir = await getApplicationDocumentsDirectory();
                    final fileName = url.split('/').last;
                    final savePath = '${dir.path}/$fileName';

                    final httpClient = HttpClient();
                    final request = await httpClient.getUrl(Uri.parse(url));
                    final response = await request.close();

                    if (response.statusCode == 200) {
                      final bytes = await response.fold<List<int>>(
                        <int>[],
                        (previous, element) => previous..addAll(element),
                      );
                      File(savePath).writeAsBytes(bytes);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloaded to $savePath')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Download failed: ${response.statusCode}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Download failed: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
            // Created/Updated Info
            Wrap(
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${protocol.createdAt != null ? DateFormat('MMMM dd, yyyy').format(protocol.createdAt!) : 'N/A'}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.update, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'Updated: ${protocol.updatedAt != null ? DateFormat('MMMM dd, yyyy').format(protocol.updatedAt!) : 'N/A'}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            // Created By
            if (protocol.createdBy != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Text('Created by: ${protocol.createdBy}', style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 