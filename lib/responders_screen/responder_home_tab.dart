import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async';
import '../models/staff.dart';
import '../models/assigned_incident.dart';
import '../services/staff_service.dart';
import '../services/staff_incidents_service.dart';
import 'incident_queue_tab.dart';
import 'incidents_map_tab.dart';
import 'staff_profile.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/session_service.dart';
import '../api/authentication.dart';
import '../login_screens/login_screen.dart';
import '../models/evacuation_center.dart';
import '../services/evacuation_center_service.dart';
import 'notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/incident_report_api.dart';

class ResponderHomeTab extends StatefulWidget {
  const ResponderHomeTab({super.key});

  @override
  State<ResponderHomeTab> createState() => _ResponderHomeTabState();
}

class _ResponderHomeTabState extends State<ResponderHomeTab> {
  Staff? _staff;
  User? _user;
  bool _isLoadingStaff = true;
  bool _isLoadingUser = true;
  bool _isLoadingIncidents = true;
  int _selectedTab = 0; // 0: Live Map, 1: Incident Queue
  List<AssignedIncident> _assignedIncidents = [];
  Map<String, dynamic> _responseStats = {};
  EvacuationCenter? _nearestEvacuationCenter;
  bool _isLoadingNearestCenter = false;
  bool _isMapFullScreen = false;

  // Map controller for zoom controls
  final MapController _mapController = MapController();

  // Location stream subscription
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _loadUser();
    _loadAssignedIncidents();
    _initializeLocation();
  }

  /// Initialize location services
  Future<void> _initializeLocation() async {
    // Check if geolocator plugin is available first
    bool pluginAvailable = await _isGeolocatorAvailable();
    if (!pluginAvailable) {
      setState(() {
        _hasLocationPermission = false;
        _gpsPluginAvailable = false;
      });
      
      // Show plugin not available dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('GPS Plugin Not Available'),
              content: const Text(
                'The GPS plugin is not properly configured. This might be due to:\n\n'
                '1. App needs to be restarted\n'
                '2. Plugin not properly installed\n'
                '3. Device compatibility issues\n\n'
                'The app will continue with simulated location for now.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _retryLocationPermission();
                  },
                  child: const Text('Retry'),
                ),
              ],
            );
          },
        );
      }
      return;
    }
    
    // Plugin is available, proceed with location permission check
    await _checkLocationPermission();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
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
        
        // If still no staff found, do nothing (no mock data).
      
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

  Future<void> _loadUser() async {
    try {
      // For staff members, we should use staff data instead of user data
      // The staff data contains the correct information from the API
      Staff? staff = await SessionService.getCurrentStaff();
      
      if (staff != null) {
        // Create a User object from staff data for compatibility
        User user = User(
          userId: staff.staffId,
          firstName: staff.name.split(' ').first,
          lastName: staff.name.split(' ').length > 1 ? staff.name.split(' ').skip(1).join(' ') : '',
          email: staff.email,
          userType: staff.role,
          department: 'Emergency Response', // Default department for staff
          college: 'Health Sciences', // Default college for staff
          status: staff.status == 'active' ? 1 : 0, // Convert string status to int
          createdAt: staff.createdAt,
        );
        
        setState(() {
          _user = user;
          _isLoadingUser = false;
        });
        return;
      }
      
      // Fallback to user service if no staff data
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
                      _staff?.name ?? _user?.fullName ?? 'Welcome, Responder',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _staff?.roleDisplayName ?? _user?.userType ?? 'Responder',
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
          builder: (context) => StaffProfileScreen(staff: _staff),
        ),
      );
    }
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

  Future<void> _loadAssignedIncidents() async {
    try {
      setState(() {
        _isLoadingIncidents = true;
      });

      // Fetch all assigned incidents (default)
      final result = await StaffIncidentsService.getAssignedIncidents();
      List<AssignedIncident> incidents = [];
      if (result['success'] == true && result['data'] != null) {
        incidents = result['data'];
      }
      final sortedIncidents = StaffIncidentsService.sortIncidentsByPriorityAndDistance(incidents);
      // Compute stats as usual, but override resolvedToday
      final stats = StaffIncidentsService.getResponseStatistics(sortedIncidents);
      // Fetch resolved today incidents for the stat using the new API method
      final resolvedTodayResult = await IncidentReportApi.getResolvedTodayIncidents();
      int resolvedTodayCount = 0;
      if (resolvedTodayResult['success'] == true && resolvedTodayResult['data'] != null) {
        resolvedTodayCount = (resolvedTodayResult['data'] as List).length;
      }
      stats['resolvedToday'] = resolvedTodayCount;
      setState(() {
        _assignedIncidents = sortedIncidents;
        _responseStats = stats;
        _isLoadingIncidents = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingIncidents = false;
      });
      print('Error loading assigned incidents: $e');
    }
  }

  // Current staff location from GPS
  LatLng _currentLocation = const LatLng(13.9411, 121.1631); // Default BSU Lipa coordinates
  bool _isLocationUpdating = false;
  bool _hasLocationPermission = false;
  bool _gpsPluginAvailable = true; // Now using real GPS
  Position? _lastKnownPosition;

  /// Check and request location permissions
  Future<void> _checkLocationPermission() async {
    try {
      print('Checking location permissions...');
      
      // Check if location services are enabled
      bool serviceEnabled;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        print('Error checking location service: $e');
        // If we can't check location service, assume it's not available
        setState(() {
          _hasLocationPermission = false;
          _gpsPluginAvailable = false;
        });
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('GPS Plugin Not Available'),
              content: const Text(
                'The GPS plugin is not properly configured. Please restart the app or check your device settings.\n\n'
                'If the problem persists, try:\n'
                '1. Restarting the app\n'
                '2. Checking location permissions in device settings\n'
                '3. Ensuring location services are enabled',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _retryLocationPermission();
                  },
                  child: const Text('Retry'),
                ),
              ],
            );
          },
        );
        return;
      }
      
      if (!serviceEnabled) {
        setState(() {
          _hasLocationPermission = false;
          _gpsPluginAvailable = false;
        });
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                'Location services are disabled. Please enable GPS in your device settings to use the map features.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Geolocator.openLocationSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Show explanation dialog before requesting permission
        bool shouldRequest = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'This app needs location access to show your position on the map and calculate distances to incidents. '
                'Your location will only be used for emergency response purposes.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Allow'),
                ),
              ],
            );
          },
        ) ?? false;

        if (shouldRequest) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            setState(() {
              _hasLocationPermission = false;
              _gpsPluginAvailable = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }
        } else {
          setState(() {
            _hasLocationPermission = false;
            _gpsPluginAvailable = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _hasLocationPermission = false;
          _gpsPluginAvailable = false;
        });
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'Location permission is permanently denied. Please enable it in your device settings to use the map features.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Permission granted
      setState(() {
        _hasLocationPermission = true;
        _gpsPluginAvailable = true;
      });
      
      // Get initial location
      await _getCurrentLocation();
    } catch (e) {
      print('Error checking location permission: $e');
      setState(() {
        _hasLocationPermission = false;
        _gpsPluginAvailable = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing location: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Get current GPS location using geolocator
  Future<void> _getCurrentLocation() async {
    if (!_hasLocationPermission) {
      print('No location permission, checking permissions...');
      await _checkLocationPermission();
      return;
    }

    // Check if geolocator plugin is available
    if (!_gpsPluginAvailable) {
      print('GPS plugin not available, using simulated location');
      _getSimulatedLocation();
      return;
    }

    try {
      print('Getting current position...');
      
      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // Increased timeout for Android
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = newLocation;
        _lastKnownPosition = position;
      });
      // Move map to new location
      _mapController.move(newLocation, _mapController.camera.zoom);

      print('Real GPS Location: ${newLocation.latitude}, ${newLocation.longitude}');
      print('Accuracy: ${position.accuracy}m, Speed: ${position.speed}m/s');
      print('Altitude: ${position.altitude}m, Heading: ${position.heading}°');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location updated: ${newLocation.latitude.toStringAsFixed(4)}, ${newLocation.longitude.toStringAsFixed(4)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      // Fetch nearest evacuation center
      _fetchNearestEvacuationCenter(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      
      // Try to get last known position as fallback
      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          final fallbackLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
          setState(() {
            _currentLocation = fallbackLocation;
            _lastKnownPosition = lastPosition;
          });
          // Move map to new location
          _mapController.move(fallbackLocation, _mapController.camera.zoom);
          // Fetch nearest evacuation center with fallback location
          _fetchNearestEvacuationCenter(lastPosition.latitude, lastPosition.longitude);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Using last known location: ${fallbackLocation.latitude.toStringAsFixed(4)}, ${fallbackLocation.longitude.toStringAsFixed(4)}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          throw Exception('No last known position available');
        }
      } catch (fallbackError) {
        // Fallback to simulated location if all else fails
        print('All GPS methods failed, using simulated location');
        _getSimulatedLocation();
      }
    }
  }

  /// Get simulated location as fallback
  void _getSimulatedLocation() {
    print('Getting simulated location...');
    
    // Simulate GPS location with slight variation
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final latOffset = (random - 500) / 100000; // Small random offset
    final lngOffset = (random - 500) / 100000;
    
    final newLocation = LatLng(
      13.9411 + latOffset, // BSU Lipa coordinates with variation
      121.1631 + lngOffset,
    );

    setState(() {
      _currentLocation = newLocation;
      _lastKnownPosition = null; // No real position data
    });
    // Move map to new location
    _mapController.move(newLocation, _mapController.camera.zoom);

    print('Simulated GPS Location: ${newLocation.latitude}, ${newLocation.longitude}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Using simulated location: ${newLocation.latitude.toStringAsFixed(4)}, ${newLocation.longitude.toStringAsFixed(4)}'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
    // Fetch nearest evacuation center with simulated location
    _fetchNearestEvacuationCenter(newLocation.latitude, newLocation.longitude);
  }

  Future<void> _updateLocation() async {
    if (_isLocationUpdating) return;
    
    setState(() {
      _isLocationUpdating = true;
    });

    try {
      // Get real GPS location
      await _getCurrentLocation();
      
      final result = await StaffIncidentsService.updateLocation(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
      );
      
      if (result['success'] == true) {
        // Reload incidents to get updated distances
        await _loadAssignedIncidents();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update location'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error updating location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLocationUpdating = false;
      });
    }
  }

  Future<void> _startLocationTracking() async {
    // Start continuous GPS tracking
    if (!_hasLocationPermission) {
      print('No location permission, requesting...');
      await _checkLocationPermission();
      return;
    }

    try {
      print('Starting location tracking...');
      // Get current location
      await _getCurrentLocation();
      
      // Update location on server
      await _updateLocation();
      
      // Start location stream for continuous updates
      _startLocationStream();
    } catch (e) {
      print('Error starting location tracking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting location tracking: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Check if running on emulator
  Future<bool> _isEmulator() async {
    try {
      // Check if we can get location - emulators often have issues
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return true;
      
      // Try to get a quick position check
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        // Try to get current position with short timeout
        try {
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 3),
          );
        } catch (e) {
          return true; // Likely emulator if we can't get position quickly
        }
      }
      
      return false;
    } catch (e) {
      return true; // Assume emulator if there are issues
    }
  }

  /// Open Android location settings
  Future<void> _openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
      // Fallback to app settings
      await Geolocator.openAppSettings();
    }
  }

  /// Retry location permission check
  Future<void> _retryLocationPermission() async {
    print('Retrying location permission check...');
    // Wait a bit before retrying
    await Future.delayed(const Duration(seconds: 1));
    await _initializeLocation();
  }

  /// Check if geolocator plugin is available
  Future<bool> _isGeolocatorAvailable() async {
    try {
      // Try a simple geolocator call to check if plugin is available
      await Geolocator.isLocationServiceEnabled();
      return true;
    } catch (e) {
      print('Geolocator plugin not available: $e');
      return false;
    }
  }

  /// Start continuous location stream
  void _startLocationStream() {
    if (!_hasLocationPermission) return;
    
    // Cancel existing subscription if any
    _locationSubscription?.cancel();
    
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );
      
      _locationSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        print('Location stream update: ${position.latitude}, ${position.longitude}');
        
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _lastKnownPosition = position;
        });
        // Move map to new location
        _mapController.move(LatLng(position.latitude, position.longitude), _mapController.camera.zoom);
      }, onError: (error) {
        print('Location stream error: $error');
      });
    } catch (e) {
      print('Error starting location stream: $e');
    }
  }

  /// Stop location tracking
  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    print('Location tracking stopped');
  }

  /// Check if location tracking is active
  bool get _isLocationTrackingActive => _locationSubscription != null;

  /// Get GPS signal quality indicator
  String get _gpsSignalQuality {
    if (_lastKnownPosition == null) return 'Unknown';
    
    final accuracy = _lastKnownPosition!.accuracy;
    if (accuracy <= 5) return 'Excellent';
    if (accuracy <= 10) return 'Good';
    if (accuracy <= 20) return 'Fair';
    if (accuracy <= 50) return 'Poor';
    return 'Very Poor';
  }

  /// Get GPS signal quality color
  Color get _gpsSignalColor {
    if (_lastKnownPosition == null) return Colors.grey;
    
    final accuracy = _lastKnownPosition!.accuracy;
    if (accuracy <= 5) return Colors.green;
    if (accuracy <= 10) return Colors.lightGreen;
    if (accuracy <= 20) return Colors.orange;
    if (accuracy <= 50) return Colors.red;
    return Colors.red.shade900;
  }

  /// Update location on server without reloading incidents
  Future<void> _updateLocationOnServer(double latitude, double longitude) async {
    try {
      await StaffIncidentsService.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      print('Error updating location on server: $e');
    }
  }

  /// Calculate optimal map center based on incidents and current location
  LatLng _getOptimalMapCenter() {
    if (_assignedIncidents.isEmpty) {
      return _currentLocation;
    }

    // Calculate bounds of all incidents
    double minLat = _assignedIncidents.first.latitude ?? _currentLocation.latitude;
    double maxLat = _assignedIncidents.first.latitude ?? _currentLocation.latitude;
    double minLng = _assignedIncidents.first.longitude ?? _currentLocation.longitude;
    double maxLng = _assignedIncidents.first.longitude ?? _currentLocation.longitude;

    for (final incident in _assignedIncidents) {
      if (incident.latitude != null && incident.longitude != null) {
        minLat = min(minLat, incident.latitude!);
        maxLat = max(maxLat, incident.latitude!);
        minLng = min(minLng, incident.longitude!);
        maxLng = max(maxLng, incident.longitude!);
      }
    }

    // Include current location in bounds
    minLat = min(minLat, _currentLocation.latitude);
    maxLat = max(maxLat, _currentLocation.latitude);
    minLng = min(minLng, _currentLocation.longitude);
    maxLng = max(maxLng, _currentLocation.longitude);

    // Return center of bounds
    return LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
  }

  /// Calculate optimal zoom level based on incident spread
  double _getOptimalZoomLevel() {
    if (_assignedIncidents.isEmpty) {
      return 12.0;
    }

    // Calculate the spread of incidents
    double maxDistance = 0;
    for (int i = 0; i < _assignedIncidents.length; i++) {
      for (int j = i + 1; j < _assignedIncidents.length; j++) {
        final incident1 = _assignedIncidents[i];
        final incident2 = _assignedIncidents[j];
        
        if (incident1.latitude != null && incident1.longitude != null &&
            incident2.latitude != null && incident2.longitude != null) {
          final distance = _calculateDistance(
            incident1.latitude!, incident1.longitude!,
            incident2.latitude!, incident2.longitude!,
          );
          maxDistance = max(maxDistance, distance);
        }
      }
    }

    // Adjust zoom based on distance
    if (maxDistance < 1) return 15.0; // Very close incidents
    if (maxDistance < 5) return 13.0; // Close incidents
    if (maxDistance < 20) return 11.0; // Medium distance
    return 9.0; // Far apart incidents
  }

  /// Calculate distance between two points in kilometers
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Get incident icon based on type
  IconData _getIncidentIcon(String incidentType) {
    switch (incidentType.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'medical':
        return Icons.medical_services;
      case 'security':
        return Icons.security;
      case 'violence':
        return Icons.warning;
      case 'utility':
        return Icons.power;
      case 'injury':
        return Icons.healing;
      case 'accident':
        return Icons.car_crash;
      case 'theft':
        return Icons.security;
      case 'vandalism':
        return Icons.build;
      case 'suspicious':
        return Icons.visibility;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  /// Get incident marker size based on priority
  double _getIncidentMarkerSize(String priorityLevel) {
    switch (priorityLevel.toLowerCase()) {
      case 'critical':
        return 60.0;
      case 'high':
        return 50.0;
      case 'medium':
        return 45.0;
      case 'low':
        return 40.0;
      default:
        return 45.0;
    }
  }

  /// Show incident details in a bottom sheet
  void _showIncidentDetails(AssignedIncident incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with incident type and priority
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: incident.priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIncidentIcon(incident.incidentType),
                              color: incident.priorityColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incident.incidentType,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: incident.priorityColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    incident.priorityLevel.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          incident.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Details grid
                      Row(
                        children: [
                          Expanded(
                            child: _DetailCard(
                              icon: Icons.location_on,
                              title: 'Location',
                              value: incident.location,
                              iconColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DetailCard(
                              icon: Icons.straighten,
                              title: 'Distance',
                              value: incident.formattedDistance,
                              iconColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailCard(
                              icon: Icons.schedule,
                              title: 'Reported',
                              value: incident.timeSinceCreation,
                              iconColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DetailCard(
                              icon: Icons.info,
                              title: 'Status',
                              value: incident.status,
                              iconColor: incident.statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.directions),
                              label: const Text('Navigate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                final lat = incident.latitude;
                                final lng = incident.longitude;
                                if (lat != null && lng != null) {
                                  final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
                                  final uri = Uri.parse(googleMapsUrl);
                                  try {
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      // Try launching in browser as a fallback
                                      if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
                                        // Opened in browser
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Could not launch navigation.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error launching navigation: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Incident location not available.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchNearestEvacuationCenter(double lat, double lng) async {
    setState(() {
      _isLoadingNearestCenter = true;
    });
    final nearest = await EvacuationCenterService.getNearestCenter(lat, lng);
    setState(() {
      _nearestEvacuationCenter = nearest;
      _isLoadingNearestCenter = false;
    });
  }

  void _fitMapToBounds() {
    setState(() {
      _isMapFullScreen = true;
    });
    final points = <LatLng>[];
    if (_currentLocation != null) {
      points.add(_currentLocation);
    }
    for (final incident in _assignedIncidents) {
      if (incident.latitude != null && incident.longitude != null) {
        points.add(LatLng(incident.latitude!, incident.longitude!));
      }
    }
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(60),
      maxZoom: 16,
      minZoom: 8,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: _isMapFullScreen
          ? Stack(
              children: [
                // Fullscreen map only
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _getOptimalMapCenter(),
                    initialZoom: _getOptimalZoomLevel(),
                    minZoom: 8.0,
                    maxZoom: 18.0,
                    onMapReady: () {
                      print('Map is ready for live tracking');
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.proteq_mobileapp',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: _currentLocation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _currentLocation,
                          color: Colors.blue.withOpacity(0.1),
                          borderColor: Colors.blue.withOpacity(0.3),
                          borderStrokeWidth: 1,
                          radius: 1000,
                        ),
                        CircleMarker(
                          point: _currentLocation,
                          color: Colors.blue.withOpacity(0.05),
                          borderColor: Colors.blue.withOpacity(0.2),
                          borderStrokeWidth: 1,
                          radius: 5000,
                        ),
                        CircleMarker(
                          point: _currentLocation,
                          color: Colors.blue.withOpacity(0.02),
                          borderColor: Colors.blue.withOpacity(0.1),
                          borderStrokeWidth: 1,
                          radius: 10000,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: _assignedIncidents
                          .where((incident) => incident.latitude != null && incident.longitude != null)
                          .map((incident) {
                        final markerSize = _getIncidentMarkerSize(incident.priorityLevel);
                        return Marker(
                          width: markerSize,
                          height: markerSize,
                          point: LatLng(incident.latitude!, incident.longitude!),
                          child: GestureDetector(
                            onTap: () => _showIncidentDetails(incident),
                            child: SizedBox(
                              width: markerSize,
                              height: markerSize,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated pulse effect for critical incidents
                                    if (incident.priorityLevel.toLowerCase() == 'critical')
                                      Container(
                                        width: markerSize + 20,
                                        height: markerSize + 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 8,
                                            height: 8,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: incident.priorityColor.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getIncidentIcon(incident.incidentType),
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            incident.incidentType,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            incident.priorityLevel,
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: incident.priorityColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // Exit full screen button
                Positioned(
                  top: 24,
                  right: 24,
                  child: FloatingActionButton.small(
                    heroTag: 'exitfullscreen',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    tooltip: 'Exit Full Screen',
                    onPressed: () {
                      setState(() {
                        _isMapFullScreen = false;
                      });
                    },
                    child: const Icon(Icons.close_fullscreen),
                  ),
                ),
                // Optionally, keep overlays like legend, etc. if desired
              ],
            )
          : Column(
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NotificationsScreen(),
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
                    ],
                  ),
                ),
               
               
                // Tab Content (scrollable)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAssignedIncidents,
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
                                          value: _isLoadingIncidents ? '...' : '${_responseStats['activeIncidents'] ?? 0}',
                                          label: 'Active Incidents',
                                          subLabel: _isLoadingIncidents ? 'Loading...' : '${_responseStats['criticalIncidents'] ?? 0} critical',
                                        ),
                                        _StatCard(
                                          icon: Icons.location_on,
                                          iconColor: Colors.green,
                                          value: _isLoadingIncidents ? '...' : '${_responseStats['nearbyIncidents'] ?? 0}',
                                          label: 'Nearby',
                                          subLabel: _isLoadingIncidents ? 'Loading...' : 'Within 1km',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _StatCard(
                                          icon: Icons.timer,
                                          iconColor: Colors.blue,
                                          value: _isLoadingIncidents ? '...' : '${_assignedIncidents.length}',
                                          label: 'Assigned',
                                          subLabel: _isLoadingIncidents ? 'Loading...' : 'Total incidents',
                                        ),
                                        _StatCard(
                                          icon: Icons.check_circle,
                                          iconColor: Colors.purple,
                                          value: _isLoadingIncidents ? '...' : '${_responseStats['resolvedToday'] ?? 0}',
                                          label: 'Resolved Today',
                                          subLabel: _isLoadingIncidents ? 'Loading...' : 'Completed',
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
                                  // Live Tracking Map
                                  Container(
                                    height: 300,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        topRight: Radius.circular(18),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        topRight: Radius.circular(18),
                                      ),
                                      child: Stack(
                                        children: [
                                          FlutterMap(
                                            mapController: _mapController,
                                            options: MapOptions(
                                              initialCenter: _getOptimalMapCenter(),
                                              initialZoom: _getOptimalZoomLevel(),
                                              minZoom: 8.0,
                                              maxZoom: 18.0,
                                              onMapReady: () {
                                                // Map is ready, can add additional setup here
                                                print('Map is ready for live tracking');
                                              },
                                            ),
                                            children: [
                                              TileLayer(
                                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                subdomains: const ['a', 'b', 'c'],
                                                userAgentPackageName: 'com.example.proteq_mobileapp',
                                              ),
                                              // Staff location marker (current user)
                                              MarkerLayer(
                                                markers: [
                                                  Marker(
                                                    width: 40.0,
                                                    height: 40.0,
                                                    point: _currentLocation,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.withOpacity(0.8),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: Colors.white, width: 2),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.blue.withOpacity(0.3),
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const Icon(
                                                        Icons.my_location,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Coverage area circles (1km, 5km, 10km)
                                              CircleLayer(
                                                circles: [
                                                  CircleMarker(
                                                    point: _currentLocation,
                                                    color: Colors.blue.withOpacity(0.1),
                                                    borderColor: Colors.blue.withOpacity(0.3),
                                                    borderStrokeWidth: 1,
                                                    radius: 1000, // 1km
                                                  ),
                                                  CircleMarker(
                                                    point: _currentLocation,
                                                    color: Colors.blue.withOpacity(0.05),
                                                    borderColor: Colors.blue.withOpacity(0.2),
                                                    borderStrokeWidth: 1,
                                                    radius: 5000, // 5km
                                                  ),
                                                  CircleMarker(
                                                    point: _currentLocation,
                                                    color: Colors.blue.withOpacity(0.02),
                                                    borderColor: Colors.blue.withOpacity(0.1),
                                                    borderStrokeWidth: 1,
                                                    radius: 10000, // 10km
                                                  ),
                                                ],
                                              ),
                                              // Incident markers
                                              MarkerLayer(
                                                markers: _assignedIncidents
                                                    .where((incident) => incident.latitude != null && incident.longitude != null)
                                                    .map((incident) {
                                                  final markerSize = _getIncidentMarkerSize(incident.priorityLevel);
                                                  return Marker(
                                                    width: markerSize,
                                                    height: markerSize,
                                                    point: LatLng(incident.latitude!, incident.longitude!),
                                                    child: GestureDetector(
                                                      onTap: () => _showIncidentDetails(incident),
                                                      child: SizedBox(
                                                        width: markerSize,
                                                        height: markerSize,
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              // Animated pulse effect for critical incidents
                                                              if (incident.priorityLevel.toLowerCase() == 'critical')
                                                                Container(
                                                                  width: markerSize + 20,
                                                                  height: markerSize + 20,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.red.withOpacity(0.3),
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                  child: const Center(
                                                                    child: SizedBox(
                                                                      width: 8,
                                                                      height: 8,
                                                                      child: CircularProgressIndicator(
                                                                        strokeWidth: 2,
                                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              Container(
                                                                padding: const EdgeInsets.all(8),
                                                                decoration: BoxDecoration(
                                                                  color: incident.priorityColor.withOpacity(0.9),
                                                                  shape: BoxShape.circle,
                                                                  border: Border.all(color: Colors.white, width: 3),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.3),
                                                                      blurRadius: 8,
                                                                      offset: const Offset(0, 4),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Icon(
                                                                  _getIncidentIcon(incident.incidentType),
                                                                  color: Colors.white,
                                                                  size: 24,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.1),
                                                                      blurRadius: 4,
                                                                      offset: const Offset(0, 2),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    Text(
                                                                      incident.incidentType,
                                                                      style: const TextStyle(
                                                                        fontSize: 10,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black87,
                                                                      ),
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                    Text(
                                                                      incident.priorityLevel,
                                                                      style: TextStyle(
                                                                        fontSize: 8,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: incident.priorityColor,
                                                                      ),
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                                                             // Live tracking indicator
                                       Positioned(
                                         top: 12, left: 12,
                                         child: Container(
                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                           decoration: BoxDecoration(
                                             color: _hasLocationPermission 
                                                 ? (_gpsPluginAvailable 
                                                     ? (_isLocationTrackingActive ? Colors.green.withOpacity(0.9) : Colors.blue.withOpacity(0.9))
                                                     : Colors.purple.withOpacity(0.9))
                                                 : Colors.orange.withOpacity(0.9),
                                             borderRadius: BorderRadius.circular(12),
                                             boxShadow: [
                                               BoxShadow(
                                                 color: Colors.black.withOpacity(0.1),
                                                 blurRadius: 4,
                                                 offset: const Offset(0, 2),
                                               ),
                                             ],
                                           ),
                                           child: Row(
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               Container(
                                                 width: 8, height: 8,
                                                 decoration: BoxDecoration(
                                                   color: Colors.white,
                                                   shape: BoxShape.circle,
                                                   boxShadow: _hasLocationPermission && _gpsPluginAvailable && _isLocationTrackingActive ? [
                                                     BoxShadow(
                                                       color: Colors.white.withOpacity(0.8),
                                                       blurRadius: 4,
                                                       spreadRadius: 1,
                                                     ),
                                                   ] : null,
                                                 ),
                                               ),
                                               const SizedBox(width: 6),
                                               Text(
                                                 _hasLocationPermission 
                                                     ? (_gpsPluginAvailable 
                                                         ? (_isLocationTrackingActive ? 'GPS Tracking' : 'GPS Ready')
                                                         : 'GPS Simulated')
                                                     : 'GPS Needed',
                                                 style: const TextStyle(
                                                   color: Colors.white,
                                                   fontSize: 12,
                                                   fontWeight: FontWeight.bold,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ),
                                                                             // Incident count indicator with details
                                       if (_assignedIncidents.isNotEmpty)
                                         Positioned(
                                           top: 12, right: 12,
                                           child: GestureDetector(
                                             onTap: () {
                                               showDialog(
                                                 context: context,
                                                 builder: (BuildContext context) {
                                                   return AlertDialog(
                                                     title: const Text('Incident Summary'),
                                                     content: Column(
                                                       mainAxisSize: MainAxisSize.min,
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                       children: [
                                                         Text('Total Incidents: ${_assignedIncidents.length}'),
                                                         const SizedBox(height: 8),
                                                         Text('Critical: ${_assignedIncidents.where((i) => i.priorityLevel.toLowerCase() == 'critical').length}'),
                                                         Text('High: ${_assignedIncidents.where((i) => i.priorityLevel.toLowerCase() == 'high').length}'),
                                                         Text('Medium: ${_assignedIncidents.where((i) => i.priorityLevel.toLowerCase() == 'medium').length}'),
                                                         Text('Low: ${_assignedIncidents.where((i) => i.priorityLevel.toLowerCase() == 'low').length}'),
                                                         const SizedBox(height: 8),
                                                         Text('Nearby (<1km): ${_assignedIncidents.where((i) => i.distance != null && i.distance! < 1.0).length}'),
                                                       ],
                                                     ),
                                                     actions: [
                                                       TextButton(
                                                         onPressed: () => Navigator.of(context).pop(),
                                                         child: const Text('Close'),
                                                       ),
                                                     ],
                                                   );
                                                 },
                                               );
                                             },
                                             child: Container(
                                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                               decoration: BoxDecoration(
                                                 color: Colors.red.withOpacity(0.9),
                                                 borderRadius: BorderRadius.circular(16),
                                                 boxShadow: [
                                                   BoxShadow(
                                                     color: Colors.black.withOpacity(0.1),
                                                     blurRadius: 4,
                                                     offset: const Offset(0, 2),
                                                   ),
                                                 ],
                                               ),
                                               child: Row(
                                                 mainAxisSize: MainAxisSize.min,
                                                 children: [
                                                   const Icon(
                                                     Icons.warning_amber_rounded,
                                                     color: Colors.white,
                                                     size: 16,
                                                   ),
                                                   const SizedBox(width: 4),
                                                   Text(
                                                     '${_assignedIncidents.length}',
                                                     style: const TextStyle(
                                                       color: Colors.white,
                                                       fontSize: 14,
                                                       fontWeight: FontWeight.bold,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             ),
                                           ),
                                         ),
                                       // GPS coordinates indicator (for debugging)
                                       if (_hasLocationPermission)
                                         Positioned(
                                           bottom: 80, left: 12,
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                             decoration: BoxDecoration(
                                               color: Colors.black.withOpacity(0.7),
                                               borderRadius: BorderRadius.circular(8),
                                             ),
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 Text(
                                                   _gpsPluginAvailable 
                                                       ? 'GPS: ${_currentLocation.latitude.toStringAsFixed(4)}, ${_currentLocation.longitude.toStringAsFixed(4)}'
                                                       : 'SIM: ${_currentLocation.latitude.toStringAsFixed(4)}, ${_currentLocation.longitude.toStringAsFixed(4)}',
                                                   style: const TextStyle(
                                                     color: Colors.white,
                                                     fontSize: 10,
                                                     fontWeight: FontWeight.w500,
                                                   ),
                                                 ),
                                                 if (_lastKnownPosition != null)
                                                   Row(
                                                     mainAxisSize: MainAxisSize.min,
                                                     children: [
                                                       Container(
                                                         width: 6,
                                                         height: 6,
                                                         decoration: BoxDecoration(
                                                           color: _gpsSignalColor,
                                                           shape: BoxShape.circle,
                                                         ),
                                                       ),
                                                       const SizedBox(width: 4),
                                                       Text(
                                                         '${_lastKnownPosition!.accuracy.toStringAsFixed(1)}m',
                                                         style: TextStyle(
                                                           color: _gpsSignalColor,
                                                           fontSize: 9,
                                                           fontWeight: FontWeight.bold,
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                               ],
                                             ),
                                           ),
                                         ),
                                       // Insert Full Zoom button here
                                       Positioned(
                                         bottom: 140,
                                         right: 12,
                                         child: FloatingActionButton.small(
                                           heroTag: 'fullzoom',
                                           backgroundColor: Colors.white,
                                           foregroundColor: Colors.red,
                                           tooltip: 'Full Zoom',
                                           onPressed: _fitMapToBounds,
                                           child: const Icon(Icons.fullscreen),
                                         ),
                                       ),
                                       // Map controls
                                       Positioned(
                                         bottom: 12, right: 12,
                                         child: Column(
                                           children: [
                                                                                           // Location update button
                                              Container(
                                                decoration: BoxDecoration(
                                                                                                  color: _hasLocationPermission 
                                                    ? (_gpsPluginAvailable 
                                                        ? (_isLocationTrackingActive ? Colors.green : Colors.blue)
                                                        : Colors.purple)
                                                    : Colors.orange,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: IconButton(
                                                  icon: _isLocationUpdating
                                                      ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                          ),
                                                        )
                                                      : Icon(
                                                          _hasLocationPermission 
                                                              ? (_isLocationTrackingActive ? Icons.location_on : Icons.my_location)
                                                              : Icons.location_off,
                                                          size: 20,
                                                          color: Colors.white,
                                                        ),
                                                  onPressed: _isLocationUpdating 
                                                      ? null 
                                                      : () {
                                                          if (!_hasLocationPermission) {
                                                            _checkLocationPermission();
                                                          } else if (_gpsPluginAvailable) {
                                                            _isLocationTrackingActive ? _stopLocationTracking() : _startLocationTracking();
                                                          } else {
                                                            _getSimulatedLocation();
                                                          }
                                                        },
                                                  tooltip: _hasLocationPermission 
                                                      ? (_gpsPluginAvailable 
                                                          ? (_isLocationTrackingActive ? 'Stop GPS Tracking' : 'Start GPS Tracking')
                                                          : 'Update Simulated Location')
                                                      : 'Enable GPS',
                                                ),
                                              ),
                                             const SizedBox(height: 8),
                                             // Refresh incidents button
                                             Container(
                                               decoration: BoxDecoration(
                                                 color: Colors.white,
                                                 borderRadius: BorderRadius.circular(8),
                                                 boxShadow: [
                                                   BoxShadow(
                                                     color: Colors.black.withOpacity(0.1),
                                                     blurRadius: 4,
                                                     offset: const Offset(0, 2),
                                                   ),
                                                 ],
                                               ),
                                               child: IconButton(
                                                 icon: _isLoadingIncidents
                                                     ? const SizedBox(
                                                         width: 16,
                                                         height: 16,
                                                         child: CircularProgressIndicator(strokeWidth: 2),
                                                       )
                                                     : const Icon(Icons.refresh, size: 20),
                                                 onPressed: _isLoadingIncidents ? null : _loadAssignedIncidents,
                                                 tooltip: 'Refresh Incidents',
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Nearby Incidents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(
                                      _isLoadingIncidents ? 'Loading...' : '${_responseStats['nearbyIncidents'] ?? 0} active',
                                      style: const TextStyle(color: Colors.black54, fontSize: 13)
                                    ),
                                  ],
                                ),
                              ),
                              if (_isLoadingIncidents)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (_assignedIncidents.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Text(
                                      'No assigned incidents',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              else
                                ..._assignedIncidents.take(3).map((incident) => GestureDetector(
                                  onTap: () => _showIncidentDetails(incident),
                                  child: _IncidentTile(
                                    color: incident.priorityColor,
                                    title: incident.incidentType,
                                    subtitle: incident.location,
                                    distance: incident.formattedDistance,
                                    time: incident.timeSinceCreation,
                                    status: incident.status,
                                    statusColor: incident.statusColor,
                                  ),
                                )),
                              const SizedBox(height: 10),
                              
                              // Debug section to show incident data (remove in production)
                              if (_assignedIncidents.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.bug_report, size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Debug: Incident Data',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.refresh, size: 16),
                                            onPressed: _loadAssignedIncidents,
                                            tooltip: 'Refresh Data',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Total incidents loaded: ${_assignedIncidents.length}'),
                                      Text('Incidents with coordinates: ${_assignedIncidents.where((i) => i.latitude != null && i.longitude != null).length}'),
                                      Text('Critical incidents: ${_assignedIncidents.where((i) => i.priorityLevel.toLowerCase() == 'critical').length}'),
                                      Text('Nearby incidents (<1km): ${_assignedIncidents.where((i) => i.distance != null && i.distance! < 1.0).length}'),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Recent incidents:',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      ..._assignedIncidents.take(3).map((incident) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: incident.priorityColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${incident.incidentType} (${incident.priorityLevel})',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            Text(
                                              incident.latitude != null 
                                                  ? '${incident.latitude!.toStringAsFixed(4)}, ${incident.longitude!.toStringAsFixed(4)}'
                                                  : 'No coordinates',
                                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      // Incident Queue Tab
                      IncidentQueueTab(
                        incidents: _assignedIncidents,
                        onAcceptIncident: (incident) {
                          // Handle accepting incident
                          print('Accepting incident: ${incident.incidentType}');
                        },
                        onStartResponse: (incident) {
                          // Handle starting response
                          print('Starting response for: ${incident.incidentType}');
                        },
                        onRefresh: () {
                          _loadAssignedIncidents();
                        },
                        onEmergencyCall: () {
                          // Handle emergency call
                          print('Emergency call initiated');
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                                    ], // <-- CLOSE children list for Column
                ), // <-- CLOSE Column
              ),
            ),
          ),
          ],
        ),
      ),
      bottomNavigationBar: _isMapFullScreen ? null : BottomNavigationBar(
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
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

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 