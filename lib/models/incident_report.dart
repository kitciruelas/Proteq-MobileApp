class IncidentReport {
  final int? reportId;
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

  IncidentReport({
    this.reportId,
    required this.userId,
    required this.incidentType,
    required this.description,
    required this.location,
    this.longitude,
    this.latitude,
    required this.priorityLevel,
    required this.safetyStatus,
    this.status = 'Pending',
    this.createdAt,
    this.updatedAt,
    this.reporterName,
    this.reporterEmail,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    return IncidentReport(
      reportId: json['report_id'],
      userId: json['user_id'] ?? 0,
      incidentType: json['incident_type'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      priorityLevel: json['priority_level'] ?? '',
      safetyStatus: json['safety_status'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      reporterName: json['reporter_name'],
      reporterEmail: json['reporter_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
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
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'user_id': userId,
      'incident_type': incidentType,
      'description': description,
      'location': location,
      'longitude': longitude,
      'latitude': latitude,
      'priority_level': priorityLevel,
      'safety_status': safetyStatus,
    };
  }
} 