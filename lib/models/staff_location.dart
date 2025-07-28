class StaffLocation {
  final int staffId;
  final String staffName;
  final String staffRole;
  final double latitude;
  final double longitude;
  final String? address;
  final String? timestamp;
  final String? lastUpdated;
  final double? distance; // Distance from a reference point
  final String? availability;
  final String? status;

  StaffLocation({
    required this.staffId,
    required this.staffName,
    required this.staffRole,
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
    this.lastUpdated,
    this.distance,
    this.availability,
    this.status,
  });

  factory StaffLocation.fromJson(Map<String, dynamic> json) {
    return StaffLocation(
      staffId: json['staff_id'] ?? json['staffId'] ?? 0,
      staffName: json['staff_name'] ?? json['name'] ?? '',
      staffRole: json['staff_role'] ?? json['role'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      timestamp: json['timestamp'],
      lastUpdated: json['last_updated'] ?? json['updated_at'],
      distance: json['distance']?.toDouble(),
      availability: json['availability'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'staff_name': staffName,
      'staff_role': staffRole,
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
      if (timestamp != null) 'timestamp': timestamp,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (distance != null) 'distance': distance,
      if (availability != null) 'availability': availability,
      if (status != null) 'status': status,
    };
  }

  // Create a copy with updated fields
  StaffLocation copyWith({
    int? staffId,
    String? staffName,
    String? staffRole,
    double? latitude,
    double? longitude,
    String? address,
    String? timestamp,
    String? lastUpdated,
    double? distance,
    String? availability,
    String? status,
  }) {
    return StaffLocation(
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      staffRole: staffRole ?? this.staffRole,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      distance: distance ?? this.distance,
      availability: availability ?? this.availability,
      status: status ?? this.status,
    );
  }

  // Check if location is valid
  bool get isValidLocation {
    return latitude >= -90 && latitude <= 90 && 
           longitude >= -180 && longitude <= 180 &&
           latitude != 0.0 && longitude != 0.0;
  }

  // Check if staff is available
  bool get isAvailable {
    return availability?.toLowerCase() == 'available' && 
           status?.toLowerCase() == 'active';
  }

  // Get formatted distance
  String get formattedDistance {
    if (distance == null) return 'Unknown';
    
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m';
    } else if (distance! < 10) {
      return '${distance!.toStringAsFixed(1)}km';
    } else {
      return '${distance!.round()}km';
    }
  }

  // Get role display name
  String get roleDisplayName {
    switch (staffRole.toLowerCase()) {
      case 'nurse':
        return 'Nurse';
      case 'paramedic':
        return 'Paramedic';
      case 'security':
        return 'Security';
      case 'firefighter':
        return 'Firefighter';
      case 'others':
        return 'Other Staff';
      default:
        return staffRole.toUpperCase();
    }
  }

  // Get availability display name
  String get availabilityDisplayName {
    switch (availability?.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'off-duty':
        return 'Off Duty';
      default:
        return availability?.toUpperCase() ?? 'Unknown';
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      default:
        return status?.toUpperCase() ?? 'Unknown';
    }
  }

  // Get availability color
  String get availabilityColor {
    switch (availability?.toLowerCase()) {
      case 'available':
        return 'green';
      case 'busy':
        return 'orange';
      case 'off-duty':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Get status color
  String get statusColor {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'green';
      case 'inactive':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  String toString() {
    return 'StaffLocation(staffId: $staffId, staffName: $staffName, staffRole: $staffRole, latitude: $latitude, longitude: $longitude, distance: $distance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffLocation &&
        other.staffId == staffId &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return staffId.hashCode ^ latitude.hashCode ^ longitude.hashCode;
  }
} 