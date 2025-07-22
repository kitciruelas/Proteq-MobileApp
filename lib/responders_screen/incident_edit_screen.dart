import 'package:flutter/material.dart';
import '../models/assigned_incident.dart';
import '../services/staff_incidents_service.dart';
import '../api/incident_report_api.dart'; // Added import for IncidentReportApi

class IncidentEditScreen extends StatefulWidget {
  final AssignedIncident incident;
  final VoidCallback? onIncidentUpdated;

  const IncidentEditScreen({
    Key? key,
    required this.incident,
    this.onIncidentUpdated,
  }) : super(key: key);

  @override
  State<IncidentEditScreen> createState() => _IncidentEditScreenState();
}

class _IncidentEditScreenState extends State<IncidentEditScreen> {
  late AssignedIncident _incident;
  bool _isLoading = false;
  bool _isSaving = false;
  
  // Form controllers
  final _notesController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  
  // Form values
  String? _selectedStatus;
  String? _selectedPriorityLevel;
  String? _selectedReporterSafeStatus;
  String? _selectedValidationStatus;

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
    _selectedStatus = _incident.status;
    _selectedPriorityLevel = _incident.priorityLevel;
    _selectedReporterSafeStatus = _incident.reporterSafeStatus;
    _selectedValidationStatus = _incident.validationStatus;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _validateIncident() async {
    if (_incident.incidentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident ID is missing! Cannot validate incident.')),
      );
      return;
    }
   
    if (_selectedValidationStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a validation status')),
      );
      return;
    }


    setState(() {
      _isSaving = true;
    });

    // Set validation_notes value based on status
    String validationNotes;
    if (_selectedValidationStatus == 'validated') {
      validationNotes = 'Validated by staff';
    } else if (_selectedValidationStatus == 'rejected') {
      validationNotes = _rejectionReasonController.text.trim();
    } else {
      validationNotes = '';
    }

    try {
      final result = await StaffIncidentsService.validateIncident(
        incidentId: _incident.incidentId!,
        validationStatus: _selectedValidationStatus!,
        rejectionReason: validationNotes, // Always send a string, even if empty
        validationNotes: validationNotes, // Always send a string, even if empty
      );

      if (result['success'] == true) {
        // Update local incident
        _incident = _incident.copyWith(
          validationStatus: _selectedValidationStatus!,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incident ${_selectedValidationStatus == 'validated' ? 'validated' : 'rejected'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onIncidentUpdated?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to validate incident'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _updateIncident() async {
    if (_incident.incidentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident ID is missing! Cannot update incident.')),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    try {
      final result = await StaffIncidentsService.updateIncident(
        incidentId: _incident.incidentId!,
        status: _selectedStatus,
        priorityLevel: _selectedPriorityLevel,
        reporterSafeStatus: _selectedReporterSafeStatus,
        notes: _notesController.text, // Always send notes, even if empty
      );

      if (result['success'] == true) {
        _incident = _incident.copyWith(
          status: _selectedStatus ?? _incident.status,
          priorityLevel: _selectedPriorityLevel ?? _incident.priorityLevel,
          reporterSafeStatus: _selectedReporterSafeStatus ?? _incident.reporterSafeStatus,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onIncidentUpdated?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update incident'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Incident'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Incident Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _incident.priorityColor.withOpacity(0.15),
                          child: Icon(
                            _getIncidentIcon(_incident.incidentType),
                            color: _incident.priorityColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _incident.incidentType,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Report #${_incident.incidentId}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _incident.validationStatusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _incident.validationStatus.toUpperCase(),
                            style: TextStyle(
                              color: _incident.validationStatusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _incident.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _incident.location,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Validation Section
            if (_incident.canValidate) ...[
              const Text(
                'Validation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validation Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedValidationStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: AssignedIncident.validationStatusValues.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.replaceAll('_', ' ').toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedValidationStatus = value;
                          });
                        },
                      ),
                      if (_selectedValidationStatus == 'rejected') ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Rejection Reason',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _rejectionReasonController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter reason for rejection...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          maxLines: 3,
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isSaving || _incident.incidentId == null) ? null : _validateIncident,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Validate Incident'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Edit Section
            if (_incident.canEdit && _incident.validationStatus != 'rejected') ...[
              const Text(
                'Edit Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status
                      const Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: AssignedIncident.statusValues.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.replaceAll('_', ' ').toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Priority Level
                      const Text(
                        'Priority Level',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPriorityLevel,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: AssignedIncident.priorityLevels.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(priority.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriorityLevel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Reporter Safe Status
                      const Text(
                        'Reporter Safe Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedReporterSafeStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: AssignedIncident.reporterSafeStatusValues.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReporterSafeStatus = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isSaving || _incident.incidentId == null) ? null : _updateIncident,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isSaving
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Updating...'),
                                  ],
                                )
                              : const Text('Update Incident'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_incident.validationStatus == 'rejected') ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.redAccent.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This incident was rejected and cannot be edited.',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Read-only information
            if (!_incident.canEdit) ...[
              const Text(
                'Incident Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Status', _incident.status.toUpperCase()),
                      _buildInfoRow('Priority', _incident.priorityLevel.toUpperCase()),
                      _buildInfoRow('Reporter Status', _incident.reporterSafeStatus.toUpperCase()),
                      _buildInfoRow('Validation', _incident.validationStatus.toUpperCase()),
                      _buildInfoRow('Created', _incident.timeSinceCreation),
                      if (_incident.assignedAt != null)
                        _buildInfoRow('Assigned', _formatDateTime(_incident.assignedAt!)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  IconData _getIncidentIcon(String incidentType) {
    switch (incidentType.toLowerCase()) {
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
} 