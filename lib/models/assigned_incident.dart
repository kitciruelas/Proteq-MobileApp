import 'package:flutter/material.dart';

class AssignedIncident {
  final int? incidentId;
  final int userId;
  final String incidentType;
  final String description;
  final String location;
  final double? longitude;
  final double? latitude;
  final String priorityLevel;
  final String safetyStatus;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String? reporterName;
  final String? reporterEmail;
  
  // Staff assignment fields
  final int? assignedStaffId;
  final String? assignedStaffName;
  final String? assignedStaffType;
  final String? assignedAt;
  final double? distance; // Distance from staff location
  final String? estimatedArrivalTime;
  
  // Validation and editing fields
  final String validationStatus;
  final String reporterSafeStatus;

  AssignedIncident({
    this.incidentId,
    required this.userId,
    required this.incidentType,
    required this.description,
    required this.location,
    this.longitude,
    this.latitude,
    required this.priorityLevel,
    required this.safetyStatus,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.reporterName,
    this.reporterEmail,
    this.assignedStaffId,
    this.assignedStaffName,
    this.assignedStaffType,
    this.assignedAt,
    this.distance,
    this.estimatedArrivalTime,
    this.validationStatus = 'unvalidated',
    this.reporterSafeStatus = 'unknown',
  });

  factory AssignedIncident.fromJson(Map<String, dynamic> json) {
    return AssignedIncident(
      incidentId: json['incident_id'] != null
          ? int.tryParse(json['incident_id'].toString())
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      userId: json['user_id'] ?? json['reported_by'] ?? 0,
      incidentType: json['incident_type'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      priorityLevel: json['priority_level'] ?? 'moderate',
      safetyStatus: json['safety_status'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? json['date_reported'],
      updatedAt: json['updated_at'],
      reporterName: json['reporter_name'] ?? ((json['reporter_first_name'] != null || json['reporter_last_name'] != null) ? '${json['reporter_first_name'] ?? ''} ${json['reporter_last_name'] ?? ''}'.trim() : null),
      reporterEmail: json['reporter_email'],
      assignedStaffId: json['assigned_staff_id'] ?? json['assigned_to'],
      assignedStaffName: json['assigned_staff_name'],
      assignedStaffType: json['assigned_staff_type'] ?? json['assigned_staff_role'],
      assignedAt: json['assigned_at'],
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : (json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null),
      estimatedArrivalTime: json['estimated_arrival_time'],
      validationStatus: json['validation_status'] ?? 'unvalidated',
      reporterSafeStatus: json['reporter_safe_status'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incident_id': incidentId,
      'user_id': userId,
      'incident_type': incidentType,
      'description': description,
      'location': location,
      'longitude': longitude,
      'latitude': latitude,
      'priority_level': priorityLevel,
      'safety_status': safetyStatus,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'reporter_name': reporterName,
      'reporter_email': reporterEmail,
      'assigned_staff_id': assignedStaffId,
      'assigned_staff_name': assignedStaffName,
      'assigned_staff_type': assignedStaffType,
      'assigned_at': assignedAt,
      'distance': distance,
      'estimated_arrival_time': estimatedArrivalTime,
      'validation_status': validationStatus,
      'reporter_safe_status': reporterSafeStatus,
    };
  }

  /// Create a copy with updated fields
  AssignedIncident copyWith({
    int? incidentId,
    int? userId,
    String? incidentType,
    String? description,
    String? location,
    double? longitude,
    double? latitude,
    String? priorityLevel,
    String? safetyStatus,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? reporterName,
    String? reporterEmail,
    int? assignedStaffId,
    String? assignedStaffName,
    String? assignedStaffType,
    String? assignedAt,
    double? distance,
    String? estimatedArrivalTime,
    String? validationStatus,
    String? reporterSafeStatus,
  }) {
    return AssignedIncident(
      incidentId: incidentId ?? this.incidentId,
      userId: userId ?? this.userId,
      incidentType: incidentType ?? this.incidentType,
      description: description ?? this.description,
      location: location ?? this.location,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      safetyStatus: safetyStatus ?? this.safetyStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      assignedStaffType: assignedStaffType ?? this.assignedStaffType,
      assignedAt: assignedAt ?? this.assignedAt,
      distance: distance ?? this.distance,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      validationStatus: validationStatus ?? this.validationStatus,
      reporterSafeStatus: reporterSafeStatus ?? this.reporterSafeStatus,
    );
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (distance == null) return 'Unknown distance';
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m away';
    } else {
      return '${distance!.toStringAsFixed(1)}km away';
    }
  }

  /// Get formatted time since creation
  String get timeSinceCreation {
    if (createdAt == null) return 'Unknown time';
    
    try {
      final created = DateTime.parse(createdAt!);
      final now = DateTime.now();
      final difference = now.difference(created);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  /// Get priority color
  Color get priorityColor {
    switch (priorityLevel.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'moderate':
        return Colors.amber;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.blue;
      case 'en route':
        return Colors.orange;
      case 'on scene':
        return Colors.purple;
      case 'resolved':
        return Colors.green;
      case 'pending':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get validation status color
  Color get validationStatusColor {
    switch (validationStatus.toLowerCase()) {
      case 'validated':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'unvalidated':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Get reporter safe status color
  Color get reporterSafeStatusColor {
    switch (reporterSafeStatus.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'injured':
        return Colors.red;
      case 'unknown':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Check if staff can validate this incident
  bool get canValidate => validationStatus == 'unvalidated';

  /// Check if staff can edit this incident
  bool get canEdit => status != 'closed' && status != 'resolved';

  /// Get available priority levels
  static List<String> get priorityLevels => ['low', 'moderate', 'high', 'critical'];

  /// Get available status values
  static List<String> get statusValues => ['pending', 'in_progress', 'resolved', 'closed'];

  /// Get available validation status values
  static List<String> get validationStatusValues => ['unvalidated', 'validated', 'rejected'];

  /// Get available reporter safe status values
  static List<String> get reporterSafeStatusValues => ['safe', 'injured', 'unknown'];
} 