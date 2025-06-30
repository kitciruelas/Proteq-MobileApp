import 'package:flutter/material.dart';

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

  final List<String> _incidentTypes = [
    'Medical',
    'Fire',
    'Violence',
    'Other',
  ];
  final List<String> _priorityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];
  final List<String> _safetyStatuses = [
    'Safe',
    'In Danger',
    'Need Assistance',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Colors.red;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Incident Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isSubmitting = true);
                            await Future.delayed(const Duration(seconds: 1));
                            setState(() => _isSubmitting = false);
                            _showSuccessDialog();
                          }
                        },
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
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryRed,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 