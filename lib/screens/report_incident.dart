import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';  // Removed - causes web package issues
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
  User? _currentUser;
  bool _isUserLoading = true;

  final List<String> _incidentTypes = [
    'Medical',
    'Fire',
    'Violence',
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
      // Create incident report object
      final incidentReport = IncidentReport(
        userId: _currentUser!.userId,
        incidentType: _incidentType!,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    const primaryRed = Colors.red;
    if (_isUserLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Incident Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              // Incident Type
              const Text('Incident Type *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _incidentType,
                hint: const Text('Select Incident Type'),
                items: _incidentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _incidentType = val),
                validator: (val) => val == null ? 'Please select an incident type' : null,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
                  helperText: 'Choose the type that best describes the incident.',
                  helperStyle: const TextStyle(color: primaryRed),
                ),
                iconEnabledColor: primaryRed,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 18),
              // Description
              const Text('Description *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter a description',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
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
              const SizedBox(height: 18),
              // Location
              const Text('Location *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter location',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryRed, width: 2),
                  ),
                  helperText: 'Provide the exact or nearest location.',
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
                validator: (val) => (val == null || val.isEmpty) ? 'Location is required' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              const Text('Additional Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              // Priority Level
              const Text('Priority Level *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  helperText: 'How urgent is this incident?',
                  helperStyle: const TextStyle(color: primaryRed),
                ),
                iconEnabledColor: primaryRed,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 18),
              // Safety Status
              const Text('Your Safety Status *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
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