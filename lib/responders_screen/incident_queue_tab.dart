import 'package:flutter/material.dart';
import '../models/assigned_incident.dart';
import '../models/staff.dart';
import '../services/staff_service.dart';
import '../services/session_service.dart';
import '../api/authentication.dart';
import '../login_screens/login_screen.dart';
import 'staff_profile.dart';
import 'incident_edit_screen.dart';
import 'incident_details_screen.dart';

class IncidentQueueTab extends StatefulWidget {
  final List<AssignedIncident> incidents;
  final Function(AssignedIncident)? onAcceptIncident;
  final Function(AssignedIncident)? onStartResponse;
  final VoidCallback? onRefresh;
  final VoidCallback? onEmergencyCall;

  const IncidentQueueTab({
    Key? key,
    required this.incidents,
    this.onAcceptIncident,
    this.onStartResponse,
    this.onRefresh,
    this.onEmergencyCall,
  }) : super(key: key);

  @override
  State<IncidentQueueTab> createState() => _IncidentQueueTabState();
}

class _IncidentQueueTabState extends State<IncidentQueueTab> {
  String selectedFilter = 'all';
  Staff? _staff;
  bool _isLoadingStaff = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      // First try to get staff from session
      Staff? staff = await SessionService.getCurrentStaff();
      
      if (staff != null) {
        setState(() {
          _staff = staff;
          _isLoadingStaff = false;
        });
        return;
      }
      
      // If no staff in session, try to get from API using user ID
      final user = await SessionService.getCurrentUser();
      if (user != null) {
        // Try to get staff by user ID (assuming user_id matches staff_id for staff members)
        staff = await StaffService.getStaffById(user.userId);
        
        if (staff != null) {
          // Store the staff data in session for future use
          await SessionService.storeStaff(staff);
          
          setState(() {
            _staff = staff;
            _isLoadingStaff = false;
          });
          return;
        }
      }
      
      
      
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

  List<AssignedIncident> get filteredIncidents {
    switch (selectedFilter) {
      case 'pending':
        return widget.incidents.where((incident) => 
          incident.status.toLowerCase() == 'pending').toList();
      case 'assigned':
        return widget.incidents.where((incident) => 
          incident.status.toLowerCase() == 'assigned').toList();
      case 'active':
        return widget.incidents.where((incident) => 
          ['en route', 'on scene', 'in_progress'].contains(incident.status.toLowerCase())).toList();
      case 'unvalidated':
        return widget.incidents.where((incident) => 
          incident.validationStatus.toLowerCase() == 'unvalidated').toList();
      default:
        return widget.incidents;
    }
  }

  String get filterCounts {
    final all = widget.incidents.length;
    final pending = widget.incidents.where((i) => i.status.toLowerCase() == 'pending').length;
    final assigned = widget.incidents.where((i) => i.status.toLowerCase() == 'assigned').length;
    final active = widget.incidents.where((i) => 
      ['en route', 'on scene', 'in_progress'].contains(i.status.toLowerCase())).length;
    final unvalidated = widget.incidents.where((i) => i.validationStatus.toLowerCase() == 'unvalidated').length;
    
    return 'All ($all) • Pending ($pending) • Assigned ($assigned) • Active ($active) • Unvalidated ($unvalidated)';
  }

  void _openEditScreen(AssignedIncident incident) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IncidentEditScreen(
          incident: incident,
          onIncidentUpdated: () {
            // Refresh the incident list
            widget.onRefresh?.call();
          },
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StaffProfileScreen(staff: _staff),
      ),
    );
  }

  void _logout() async {
    // Show confirmation dialog
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

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Call logout API
      await AuthenticationApi.logout();

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Even if logout API fails, clear local session and navigate
      await SessionService.clearSession();
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('Incident Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Live Updates', style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(width: 12),
                // Removed PopupMenuButton (profile/logout menu)
              ],
            ),
            const SizedBox(height: 16),
            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All ( ${widget.incidents.length})'),
                    selected: selectedFilter == 'all',
                    selectedColor: Colors.red,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedFilter == 'all' ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Pending ( ${widget.incidents.where((i) => i.status.toLowerCase() == 'pending').length})'),
                    selected: selectedFilter == 'pending',
                    selectedColor: Colors.red,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedFilter == 'pending' ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedFilter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Assigned ( ${widget.incidents.where((i) => i.status.toLowerCase() == 'assigned').length})'),
                    selected: selectedFilter == 'assigned',
                    selectedColor: Colors.red,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedFilter == 'assigned' ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedFilter = 'assigned'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Active ( ${widget.incidents.where((i) => ['en route', 'on scene', 'in_progress'].contains(i.status.toLowerCase())).length})'),
                    selected: selectedFilter == 'active',
                    selectedColor: Colors.red,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedFilter == 'active' ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedFilter = 'active'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Unvalidated ( ${widget.incidents.where((i) => i.validationStatus.toLowerCase() == 'unvalidated').length})'),
                    selected: selectedFilter == 'unvalidated',
                    selectedColor: Colors.red,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedFilter == 'unvalidated' ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedFilter = 'unvalidated'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Incident Cards
            if (filteredIncidents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No incidents found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              Column(
                children: filteredIncidents.map((incident) => _IncidentCard(
                  incident: incident,
                  onAccept: widget.onAcceptIncident,
                  onStartResponse: widget.onStartResponse,
                  onEdit: () => _openEditScreen(incident),
                )).toList(),
              ),
            const SizedBox(height: 16),
            // Action Buttons
          ],
        ),
      ),
    );
  }
}

class _IncidentFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  
  const _IncidentFilterChip({
    required this.label, 
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final AssignedIncident incident;
  final Function(AssignedIncident)? onAccept;
  final Function(AssignedIncident)? onStartResponse;
  final VoidCallback? onEdit;

  const _IncidentCard({
    required this.incident,
    this.onAccept,
    this.onStartResponse,
    this.onEdit,
  });

  IconData get _getIncidentIcon {
    switch (incident.incidentType.toLowerCase()) {
      case 'medical':
      case 'medical emergency':
        return Icons.medical_services;
      case 'fire':
      case 'fire alert':
        return Icons.local_fire_department;
      case 'security':
      case 'security issue':
        return Icons.security;
      case 'accident':
        return Icons.car_crash;
      case 'evacuation':
        return Icons.exit_to_app;
      default:
        return Icons.warning;
    }
  }

  String? get _getActionLabel {
    switch (incident.status.toLowerCase()) {
      case 'pending':
        return null; // Remove Accept button
      case 'assigned':
        return 'Start Response';
      case 'en route':
        return 'Update Status';
      case 'on scene':
        return 'Mark Resolved';
      default:
        return null;
    }
  }

  Color? get _getActionColor {
    switch (incident.status.toLowerCase()) {
      case 'pending':
        return null; // No color for removed Accept button
      case 'assigned':
        return Colors.red;
      case 'en route':
        return Colors.orange;
      case 'on scene':
        return Colors.purple;
      default:
        return null;
    }
  }

  VoidCallback? get _getActionCallback {
    final actionLabel = _getActionLabel;
    if (actionLabel == 'Start Response' && onStartResponse != null) {
      return () => onStartResponse!(incident);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IncidentDetailsScreen(incident: incident),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 3,
        color: Colors.white,
        shadowColor: Colors.red.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.12),
                    child: Icon(_getIncidentIcon, color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.incidentType,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: incident.validationStatusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            incident.validationStatus.toUpperCase(),
                            style: TextStyle(
                              color: incident.validationStatusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      incident.status,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                incident.description,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                incident.location,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (incident.distance != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          incident.formattedDistance,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(width: 14),
                      ],
                    ),
                  if (incident.estimatedArrivalTime != null)
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.red, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          'ETA:  ${incident.estimatedArrivalTime}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  const Spacer(),
                  if (_getActionLabel != null && _getActionColor != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getActionColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: _getActionCallback,
                      child: Text(
                        _getActionLabel!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.red),
                    onPressed: onEdit,
                    tooltip: 'Edit Incident',
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