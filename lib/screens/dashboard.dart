import 'package:flutter/material.dart';
import 'report_incident.dart';
import 'welfare_check.dart';
import 'evacuation_centers.dart';
import 'safety_protocols.dart';
import 'profile.dart';
import '../services/user_service.dart';
import '../services/alerts_service.dart';
import '../models/user.dart';
import '../models/alert.dart';
import '../login_screens/login_screen.dart';
import 'alerts_screen.dart';

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
  Alert? _currentAlert;
  bool _isLoadingAlert = true;

  static const List<String> _titles = [
    'Home',
    'Report Incident',
    'Welfare Check',
    'Evacuation Centers',
    'Safety Protocols',
  ];

  final List<_SafetyTip> _safetyTips = const [
    _SafetyTip(
      title: 'During an Earthquake',
      description: 'Drop, Cover, and Hold On. Stay away from windows and heavy objects.',
      type: 'Earthquake',
    ),
    _SafetyTip(
      title: 'Fire Safety',
      description: 'Use stairs, not elevators. Stay low to avoid smoke. Know your exits.',
      type: 'Fire',
    ),
    _SafetyTip(
      title: 'Medical Emergency',
      description: 'Call for help immediately. Provide first aid if trained.',
      type: 'Medical',
    ),
    _SafetyTip(
      title: 'Intruder Alert',
      description: 'Lock doors, stay quiet, and hide. Call security if safe to do so.',
      type: 'Intrusion',
    ),
    _SafetyTip(
      title: 'General Safety',
      description: 'Be aware of your surroundings. Report suspicious activity.',
      type: 'General',
    ),
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
    _loadLatestAlert();
  }

  Future<void> _loadUser() async {
    try {
      // Replace 1 with the actual logged-in user's ID
      User? user = await UserService.getUserById(1);
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

  Future<void> _loadLatestAlert() async {
    try {
      setState(() {
        _isLoadingAlert = true;
      });
      
      Alert? latestAlert = await AlertsService.getLatestAlert();
      setState(() {
        _currentAlert = latestAlert;
        _isLoadingAlert = false;
        _showAlert = latestAlert != null;
      });
    } catch (e) {
      setState(() {
        _isLoadingAlert = false;
        _showAlert = false;
      });
    }
  }

  void _toggleProfileDropdown(TapDownDetails details) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem<Never>(
          enabled: false,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user?.fullName ?? 'Welcome, User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _user?.userType ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person, color: Colors.red),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
    if (result == 'logout') {
      _logout();
    } else if (result == 'profile') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(user: _user),
        ),
      );
    }
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;
    // Navigate to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildHomeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Bar (fixed, full width)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.shade50,
                Colors.white,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              const SizedBox(width: 20),
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AlertsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTapDown: _toggleProfileDropdown,
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                // Emergency Alert Card
                if (_isLoadingAlert)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading alerts...', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_showAlert && _currentAlert != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getAlertCardColor(_currentAlert!.alertType, _currentAlert!.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _getAlertCardColor(_currentAlert!.alertType, _currentAlert!.priority).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Icon(
                              _getAlertIcon(_currentAlert!.alertType),
                              color: _getAlertCardColor(_currentAlert!.alertType, _currentAlert!.priority),
                              size: 48,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildSeverityChip(_currentAlert!.priority),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _currentAlert!.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: _getAlertCardColor(_currentAlert!.alertType, _currentAlert!.priority),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_currentAlert!.message.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentAlert!.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showAlert = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.emergency,
                              title: 'Report\nIncident',
                              color: Colors.red,
                              onTap: () {
                                setState(() {
                                  _selectedIndex = 1;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.health_and_safety,
                              title: 'Welfare\nCheck',
                              color: Colors.green,
                              onTap: () {
                                setState(() {
                                  _selectedIndex = 2;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.location_on,
                              title: 'Find\nShelter',
                              color: Colors.blue,
                              onTap: () {
                                setState(() {
                                  _selectedIndex = 3;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Safety Tips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Safety Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      ..._safetyTips.map((tip) => _buildSafetyTipCard(tip)).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Emergency Contacts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildContactRow('Campus Security', '911', Icons.security),
                            const Divider(height: 16),
                            _buildContactRow('Health Center', '(555) 123-4567', Icons.local_hospital),
                            const Divider(height: 16),
                            _buildContactRow('Emergency Hotline', '1-800-EMERGENCY', Icons.phone),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
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
                radius: 20,
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyTipCard(_SafetyTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getColorFromType(tip.type).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColorFromType(tip.type).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getIconFromType(tip.type), color: _getColorFromType(tip.type), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _getColorFromType(tip.type)),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String name, String contact, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                contact,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.red, size: 20),
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
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

  Widget _buildSeverityChip(String severity) {
    String label;
    Color color;
    switch (severity.toLowerCase()) {
      case 'high':
      case 'emergency':
        label = 'EMERGENCY';
        color = Colors.red;
        break;
      case 'warning':
        label = 'WARNING';
        color = Colors.orange;
        break;
      case 'info':
        label = 'INFO';
        color = Colors.blue;
        break;
      case 'medium':
        label = 'MEDIUM';
        color = Colors.orange;
        break;
      case 'low':
        label = 'LOW';
        color = Colors.green;
        break;
      default:
        label = severity.toUpperCase();
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
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

class _SafetyTip {
  final String title;
  final String description;
  final String type;
  const _SafetyTip({required this.title, required this.description, required this.type});
}

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