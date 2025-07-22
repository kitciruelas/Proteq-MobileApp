import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/incident_report.dart';
import '../models/user.dart';
import '../services/session_service.dart';
import '../api/incident_report_api.dart';
import 'dashboard.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _incidentType;
  String? _priorityLevel;
  String? _safetyStatus;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  User? _currentUser;
  bool _isUserLoading = true;

  final List<String> _incidentTypes = [
    'Medical',
    'Fire',
    'Other',
  ];
  final List<String> _priorityLevels = [
    'Low',
    'Moderate',
    'High',
    'Critical',
  ];
  final List<String> _safetyStatuses = [
    'safe',
    'injured',
    'unknown',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await SessionService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isUserLoading = false;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted'),
        content: const Text('Thank you for reporting the incident. Our team will review it promptly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    // Wait for user to load
    if (_isUserLoading) {
      _showErrorDialog('Loading user information. Please wait.');
      return;
    }
    // Check if user is available
    if (_currentUser == null) {
      _showErrorDialog('User information not available. Please log in again.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Parse coordinates if location contains them
      double? latitude;
      double? longitude;
      String locationText = _locationController.text.trim();
      
      // Check if location contains coordinates (format: "lat, long")
      if (locationText.contains(',') && locationText.contains('.')) {
        try {
          List<String> parts = locationText.split(',');
          if (parts.length == 2) {
            latitude = double.tryParse(parts[0].trim());
            longitude = double.tryParse(parts[1].trim());
          }
        } catch (e) {
          // If parsing fails, keep as text location
          latitude = null;
          longitude = null;
        }
      }

      // Create incident report object
      final incidentReport = IncidentReport(
        userId: _currentUser!.userId,
        incidentType: _incidentType!,
        description: _descriptionController.text.trim(),
        location: locationText,
        latitude: latitude,
        longitude: longitude,
        priorityLevel: _priorityLevel!,
        safetyStatus: _safetyStatus!,
        reporterName: _currentUser!.fullName,
        reporterEmail: _currentUser!.email,
      );

      // Submit report via API
      final result = await IncidentReportApi.submitIncidentReport(incidentReport);

      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        // Check if authentication is required
        if (result['requiresAuth'] == true) {
          _showErrorDialog('${result['message']}\n\nPlease log in again and try submitting your report.');
        } else {
          _showErrorDialog(result['message'] ?? 'Failed to submit report. Please try again.');
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showErrorDialog('An error occurred: $e');
    }
  }

  // Helper: Show rationale before requesting location permission
  Future<bool> _showLocationPermissionRationale() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs access to your location to automatically fill in your current coordinates for the incident report. Your location will only be used for this report.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            child: const Text('Allow', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    return result == true;
  }

  // Helper: Show dialog to open device location settings
  Future<void> _showOpenLocationSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled. Please enable location services (GPS) in your device settings to use this feature.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            child: const Text('Open Settings', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // Helper: Show dialog to open app settings (for permission denied forever)
  Future<void> _showOpenSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permissions are permanently denied. Please open app settings to enable location access.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            child: const Text('Open Settings', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    // Show rationale dialog first
    final allow = await _showLocationPermissionRationale();
    if (!allow) return;

    setState(() => _isGettingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isGettingLocation = false);
        await _showOpenLocationSettingsDialog();
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Location permission denied. Please enable location permission to use this feature.');
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isGettingLocation = false);
        await _showOpenSettingsDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Format the location as coordinates with better precision
      String locationText = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      
      setState(() {
        _locationController.text = locationText;
        _isGettingLocation = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordinates obtained successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {
      setState(() => _isGettingLocation = false);
      _showErrorDialog('Failed to get location: $e');
    }
  }

  Future<void> _showSubmitConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit this incident report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _submitReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Colors.red;
    if (_isUserLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(4.0),
            children: [
              const SizedBox(height: 8),
              // Incident Type
              const Text('Incident Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _incidentType,
                autofocus: true,
                hint: const Text('Select Incident Type'),
                items: _incidentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _incidentType = val),
                validator: (val) => val == null ? 'Please select an incident type' : null,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  helperText: 'Choose the type that best describes the incident.',
                  helperStyle: const TextStyle(color: primaryRed),
                ),
                iconEnabledColor: primaryRed,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 24),
              // Description
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Enter a description',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.description, color: Colors.red),
                  helperText: 'Describe what happened in detail.',
                  helperStyle: const TextStyle(color: primaryRed),
                  suffixIcon: _descriptionController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: primaryRed),
                          onPressed: () {
                            setState(() {
                              _descriptionController.clear();
                            });
                          },
                        )
                      : null,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Description is required' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // Location
              const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Enter location or tap button for GPS coordinates',
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: primaryRed, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                        helperText: 'Tap the location button to get your current GPS coordinates automatically.',
                        helperStyle: const TextStyle(color: primaryRed),
                        suffixIcon: _locationController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: primaryRed),
                                onPressed: () {
                                  setState(() {
                                    _locationController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Location is required';
                        }
                        // Check if it's coordinates format
                        if (val.contains(',') && val.contains('.')) {
                          List<String> parts = val.split(',');
                          if (parts.length == 2) {
                            double? lat = double.tryParse(parts[0].trim());
                            double? lng = double.tryParse(parts[1].trim());
                            if (lat == null || lng == null) {
                              return 'Invalid coordinate format. Use: latitude, longitude';
                            }
                            if (lat < -90 || lat > 90) {
                              return 'Invalid latitude. Must be between -90 and 90';
                            }
                            if (lng < -180 || lng > 180) {
                              return 'Invalid longitude. Must be between -180 and 180';
                            }
                          }
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56, // Match the height of the TextFormField
                    child: ElevatedButton(
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: _isGettingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Additional Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              // Priority Level
              const Text('Priority Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _priorityLevel,
                hint: const Text('Select Priority Level'),
                items: _priorityLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                onChanged: (val) => setState(() => _priorityLevel = val),
                validator: (val) => val == null ? 'Please select a priority level' : null,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.priority_high, color: Colors.red),
                  helperText: 'How urgent is this incident?',
                  helperStyle: const TextStyle(color: primaryRed),
                ),
                iconEnabledColor: primaryRed,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 24),
              // Safety Status
              const Text('Your Safety Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _safetyStatus,
                hint: const Text('Select Safety Status'),
                items: _safetyStatuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                onChanged: (val) => setState(() => _safetyStatus = val),
                validator: (val) => val == null ? 'Please select your safety status' : null,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.health_and_safety, color: Colors.red),
                  helperText: 'Let us know if you are safe or need help.',
                  helperStyle: const TextStyle(color: primaryRed),
                ),
                iconEnabledColor: primaryRed,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 32),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _showSubmitConfirmationDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                          minimumSize: const Size(0, 56), // Larger tap target
                        ),
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text('Submit Report', style: TextStyle(color: Colors.white)),
                      ),
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
} 