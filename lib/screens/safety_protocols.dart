import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SafetyProtocolsScreen extends StatefulWidget {
  const SafetyProtocolsScreen({super.key});

  @override
  State<SafetyProtocolsScreen> createState() => _SafetyProtocolsScreenState();
}

class _SafetyProtocolsScreenState extends State<SafetyProtocolsScreen> {
  final List<Protocol> protocols = [
    Protocol(
      type: 'Fire',
      icon: Icons.local_fire_department,
      color: Colors.red,
      title: 'Fire Safety',
      description: 'Procedures for fire emergencies, including evacuation routes and assembly points.',
      steps: [
        'Activate the nearest fire alarm pull station.',
        'Evacuate the building using the nearest exit.',
        'Proceed to the designated assembly point.'
      ],
      attachment: 'Fire Safety Map.pdf',
      date: DateTime(2025, 6, 7),
    ),
    Protocol(
      type: 'Earthquake',
      icon: Icons.place,
      color: Colors.orange,
      title: 'Earthquake Safety',
      description: 'Guidelines for staying safe during an earthquake.',
      steps: [
        'Drop, Cover, and Hold On.',
        'Stay away from windows and heavy objects.',
        'Evacuate only when shaking stops.'
      ],
      attachment: 'Earthquake Guide.pdf',
      date: DateTime(2025, 5, 20),
    ),
    Protocol(
      type: 'Medical',
      icon: Icons.medical_services,
      color: Colors.cyan,
      title: 'Medical Emergency',
      description: 'Steps to take in case of a medical emergency.',
      steps: [
        'Call emergency services immediately.',
        'Provide first aid if trained.',
        'Stay with the person until help arrives.'
      ],
      attachment: 'First Aid.pdf',
      date: DateTime(2025, 4, 10),
    ),
    // Add more protocols as needed
  ];

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
  Widget build(BuildContext context) {
    final filteredProtocols = protocols.where((protocol) {
      final matchesFilter = selectedFilter == 'All' || protocol.type == selectedFilter;
      final matchesSearch = protocol.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          protocol.description.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
   
    
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(8),
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
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 18),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: filters.map((filter) {
                    return _FilterChip(
                      label: filter.label,
                      icon: filter.icon,
                      color: filter.color,
                      selected: selectedFilter == filter.label,
                      onSelected: () {
                        setState(() {
                          selectedFilter = filter.label;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // Emergency Contacts Heading
              const Text(
                'Emergency Contacts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
              ),
              const SizedBox(height: 8),
              // Emergency Contacts Card
              Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFFF4CC),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: const [
                      Icon(Icons.call, color: Colors.amber, size: 28),
                      SizedBox(width: 8),
                      Text('In case of emergency, contact:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Emergency Contacts List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _ContactCard(
                    icon: Icons.local_police,
                    label: 'Emergency',
                    value: '911',
                    color: Colors.red,
                  ),
                  _ContactCard(
                    icon: Icons.security,
                    label: 'Security',
                    value: '(555) 123-4567',
                    color: Colors.purple,
                  ),
                  _ContactCard(
                    icon: Icons.medical_services,
                    label: 'Medical',
                    value: '(555) 987-6543',
                    color: Colors.cyan,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Protocols Heading
              const Text(
                'Safety Protocols',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
              ),
              const SizedBox(height: 8),
              // Protocol Cards
              if (filteredProtocols.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'No protocols found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...filteredProtocols.map((protocol) => _ProtocolCard(protocol: protocol)).toList(),
            ],
          ),
        ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;
  const _FilterChip({required this.label, required this.icon, required this.color, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
        selected: selected,
        selectedColor: color.withOpacity(0.1),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: color)),
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class Protocol {
  final String type;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<String> steps;
  final String attachment;
  final DateTime date;

  Protocol({
    required this.type,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.steps,
    required this.attachment,
    required this.date,
  });
}

class _ProtocolCard extends StatelessWidget {
  final Protocol protocol;
  const _ProtocolCard({required this.protocol});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(protocol.icon, color: protocol.color, size: 32),
                  const SizedBox(width: 10),
                  Text(protocol.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: protocol.color)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                protocol.description,
                style: TextStyle(color: protocol.color, fontSize: 15),
              ),
              const SizedBox(height: 16),
              ...protocol.steps.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: protocol.color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(step, style: TextStyle(color: Colors.black87))),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    label: Text('View Attachment', style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: protocol.color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Attachment: \'${protocol.attachment}\'')),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(DateFormat('MMMM dd, yyyy').format(protocol.date), style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _ContactCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
} 