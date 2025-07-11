import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/staff_service.dart';
import 'incident_queue_tab.dart';
import 'incidents_map_tab.dart';
import '../screens/profile.dart';

class ResponderHomeTab extends StatefulWidget {
  const ResponderHomeTab({super.key});

  @override
  State<ResponderHomeTab> createState() => _ResponderHomeTabState();
}

class _ResponderHomeTabState extends State<ResponderHomeTab> {
  Staff? _staff;
  bool _isLoadingStaff = true;
  int _selectedTab = 0; // 0: Live Map, 1: Incident Queue

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      // Replace 1 with the actual logged-in staff's ID
      Staff? staff = await StaffService.getStaffById(1);
      setState(() {
        _staff = staff;
        _isLoadingStaff = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStaff = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Logo image replacing CircleAvatar and text
                  Image.asset(
                    'assets/images/logo-r.png',
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Proteq',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, size: 28),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.person, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
           
           
            // Tab Content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTab == 0) ...[
                      // Response Overview Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Response Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8, height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.green, shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text('Real-time', style: TextStyle(color: Colors.black54, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _StatCard(
                                      icon: Icons.warning_amber_rounded,
                                      iconColor: Colors.red,
                                      value: '8',
                                      label: 'Active Incidents',
                                      subLabel: '+2 from last hour',
                                    ),
                                    _StatCard(
                                      icon: Icons.groups,
                                      iconColor: Colors.green,
                                      value: '12',
                                      label: 'Available Teams',
                                      subLabel: '3 on standby',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _StatCard(
                                      icon: Icons.timer,
                                      iconColor: Colors.blue,
                                      value: '4.2m',
                                      label: 'Avg Response',
                                      subLabel: '-30s from yesterday',
                                    ),
                                    _StatCard(
                                      icon: Icons.check_circle,
                                      iconColor: Colors.purple,
                                      value: '24',
                                      label: 'Resolved Today',
                                      subLabel: '92% success rate',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Map & Incidents Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                          child: Column(
                            children: [
                              // Map Placeholder
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                  color: Colors.grey[300],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(Icons.map, color: Colors.grey[500], size: 80),
                                    ),
                                    Positioned(
                                      top: 12, left: 12,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8, height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.green, shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('Live Tracking Active', style: TextStyle(color: Colors.black87, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Nearby Incidents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('3 active', style: TextStyle(color: Colors.black54, fontSize: 13)),
                                  ],
                                ),
                              ),
                              _IncidentTile(
                                color: Colors.orange,
                                title: 'Medical Emergency',
                                subtitle: 'Building A - Floor 3',
                                distance: '0.2 km away',
                                time: '2 min ago',
                                status: 'Available',
                                statusColor: Colors.green,
                              ),
                              _IncidentTile(
                                color: Colors.red,
                                title: 'Fire Alert',
                                subtitle: 'Building B - Kitchen',
                                distance: '0.5 km away',
                                time: '5 min ago',
                                status: 'En Route',
                                statusColor: Colors.blue,
                              ),
                              _IncidentTile(
                                color: Colors.amber,
                                title: 'Security Issue',
                                subtitle: 'Parking Area C',
                                distance: '0.8 km away',
                                time: '8 min ago',
                                status: 'Available',
                                statusColor: Colors.green,
                              ),
                              const SizedBox(height: 10),
                              // Action Buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
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
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        onPressed: () {},
                                        child: const Text('Navigate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      // Incident Queue Tab
                      IncidentQueueTab(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Live Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Incident Queue',
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.grey[200],
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String subLabel;
  const _StatCard({required this.icon, required this.iconColor, required this.value, required this.label, required this.subLabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(subLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final String distance;
  final String time;
  final String status;
  final Color statusColor;
  const _IncidentTile({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: color, shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                Text(distance, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 4),
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
        ],
      ),
    );
  }
} 