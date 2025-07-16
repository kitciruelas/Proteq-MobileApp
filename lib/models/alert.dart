class Alert {
  final int alertId;
  final String title;
  final String message;
  final String alertType;
  final String priority;
  final String status;
  final DateTime? scheduledTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int createdBy;
  final String? location;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  Alert({
    required this.alertId,
    required this.title,
    required this.message,
    required this.alertType,
    required this.priority,
    required this.status,
    this.scheduledTime,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.location,
    required this.isActive,
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      alertId: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['description'] ?? '',
      alertType: json['alert_type'] ?? '',
      priority: json['alert_severity'] ?? 'medium',
      status: json['status'] ?? 'active',
      scheduledTime: json['scheduled_time'] != null 
          ? DateTime.tryParse(json['scheduled_time']) 
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
      createdBy: json['created_by'] ?? json['user_id'] ?? 0,
      location: json['location'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      radiusKm: json['radius_km'] != null ? double.tryParse(json['radius_km'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': alertId,
      'title': title,
      'description': message,
      'alert_type': alertType,
      'alert_severity': priority,
      'status': status,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'location': location,
      'is_active': isActive ? 1 : 0,
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
    };
  }

  bool get isHighPriority => priority.toLowerCase() == 'high';
  bool get isEmergency => alertType.toLowerCase() == 'emergency';
  bool get isDrill => alertType.toLowerCase() == 'drill';
  bool get isEarthquake => alertType.toLowerCase() == 'earthquake';
  bool get isInfo => alertType.toLowerCase() == 'info';
  
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      case 'low':
        return 'green';
      default:
        return 'blue';
    }
  }

  String get alertTypeIcon {
    switch (alertType.toLowerCase()) {
      case 'emergency':
        return '🚨';
      case 'drill':
        return '🏃';
      case 'earthquake':
        return '🌋';
      case 'info':
        return 'ℹ️';
      case 'warning':
        return '⚠️';
      default:
        return '📢';
    }
  }
} 