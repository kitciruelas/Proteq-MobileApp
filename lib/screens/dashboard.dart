import 'package:flutter/material.dart';
import 'report_incident.dart';
import 'welfare_check.dart';
import 'evacuation_centers.dart';
import 'safety_protocols.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class DashboardScreen extends StatefulWidget {
  final User? user;
  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showAlert = true;
  int _selectedIndex = 0;
  User? _user;
  bool _isLoadingUser = true;

  static const List<String> _titles = [
    'Home',
    'Report Incident',
    'Welfare Check',
    'Evacuation Centers',
    'Safety Protocols',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _user = widget.user;
      _isLoadingUser = false;
    } else {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    try {
      // Replace 1 with the actual logged-in user's ID
      User user = await UserService.fetchUser(1);
      setState(() {
        _user = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Greeting Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 22,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isLoadingUser
                          ? const Text('Loading...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                          : Text(
                              _user != null
                                  ? '${_user!.fullName}'
                                  : 'Welcome, User',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                      _isLoadingUser
                          ? const Text('', style: TextStyle(color: Colors.grey, fontSize: 14))
                          : Text(
                              _user != null ? _user!.userType : '',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_active, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Emergency Alert Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("ALERT: Earthquake Drill at 9:30 AM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Emergency Overview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Emergency Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Incidents
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.report, color: Colors.red, size: 28),
                            SizedBox(height: 8),
                            Text('3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Incidents', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                    // People Safe
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.people, color: Colors.green, size: 28),
                            SizedBox(height: 8),
                            Text('120', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Safe', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                    // Resources
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.local_drink, color: Colors.blue, size: 28),
                            SizedBox(height: 8),
                            Text('Water', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Available', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Emergency Plan/Resources
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Evacuation Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('See all', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                          ),
                        ),
                        child: const Icon(Icons.map, color: Colors.red, size: 40),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Nearest Center: Main Gym', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              SizedBox(height: 4),
                              Text('Evacuation Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Follow the marked route to the main gym for safety.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 18,
                          child: Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResponderButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return ReportIncidentScreen(key: ValueKey('dashboard_report_incident_$index'));
      case 2:
        return WelfareCheckScreen(key: ValueKey('dashboard_welfare_check_$index'));
      case 3:
        return EvacuationCentersScreen(key: ValueKey('dashboard_evacuation_centers_$index'));
      case 4:
        return SafetyProtocolsScreen(key: ValueKey('dashboard_safety_protocols_$index'));
      default:
        return _buildHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _getScreen(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              tooltip: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.report),
              label: 'Report',
              tooltip: 'Report Incident',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Welfare',
              tooltip: 'Welfare Check',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'Evacuation',
              tooltip: 'Evacuation Centers',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: 'Safety',
              tooltip: 'Safety Protocols',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}