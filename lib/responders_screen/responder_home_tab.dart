import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/staff_service.dart';

class ResponderHomeTab extends StatefulWidget {
  const ResponderHomeTab({super.key});

  @override
  State<ResponderHomeTab> createState() => _ResponderHomeTabState();
}

class _ResponderHomeTabState extends State<ResponderHomeTab> {
  Staff? _staff;
  bool _isLoadingStaff = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      // Replace 1 with the actual logged-in staff's ID
      Staff staff = await StaffService.fetchStaff(1);
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
                      _isLoadingStaff
                          ? const Text('Loading...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                          : Text(
                              _staff != null
                                  ? '${_staff!.name}'
                                  : 'Welcome, Staff',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                      _isLoadingStaff
                          ? const Text('', style: TextStyle(color: Colors.grey, fontSize: 14))
                          : Text(
                              _staff != null ? '${_staff!.role} | ${_staff!.availability}' : '',
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
} 