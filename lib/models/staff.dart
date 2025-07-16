class Staff {
  final int staffId;
  final String name;
  final String email;
  final String role;
  final String availability;
  final String status;
  final String createdAt;
  final String updatedAt;

  Staff({
    required this.staffId,
    required this.name,
    required this.email,
    required this.role,
    required this.availability,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    // Handle status conversion from number to string
    String status;
    if (json['status'] is int) {
      status = json['status'] == 1 ? 'active' : 'inactive';
      print('[Staff.fromJson] Converting status from int ${json['status']} to string: $status');
    } else if (json['status'] is String) {
      status = json['status'];
      print('[Staff.fromJson] Status is already string: $status');
    } else {
      status = 'active'; // default
      print('[Staff.fromJson] Status is neither int nor string, using default: $status');
    }

    print('[Staff.fromJson] Creating Staff object with name: ${json['name']}, role: ${json['role']}, status: $status');

    return Staff(
      staffId: json['staff_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      availability: json['availability'] ?? 'available',
      status: status,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Convert status string back to number for API compatibility
    int statusValue;
    switch (status.toLowerCase()) {
      case 'active':
        statusValue = 1;
        break;
      case 'inactive':
        statusValue = 0;
        break;
      default:
        statusValue = 1; // default to active
    }

    return {
      'staff_id': staffId,
      'name': name,
      'email': email,
      'role': role,
      'availability': availability,
      'status': statusValue,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper getters
  bool get isActive => status.toLowerCase() == 'active';
  bool get isAvailable => availability.toLowerCase() == 'available';
  bool get isBusy => availability.toLowerCase() == 'busy';
  bool get isOffDuty => availability.toLowerCase() == 'off-duty';

  // Role-specific getters
  bool get isNurse => role.toLowerCase() == 'nurse';
  bool get isParamedic => role.toLowerCase() == 'paramedic';
  bool get isSecurity => role.toLowerCase() == 'security';
  bool get isFirefighter => role.toLowerCase() == 'firefighter';
  bool get isOtherRole => role.toLowerCase() == 'others';

  // Availability color getter
  String get availabilityColor {
    switch (availability.toLowerCase()) {
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

  // Status color getter
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return 'green';
      case 'inactive':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Role display name
  String get roleDisplayName {
    switch (role.toLowerCase()) {
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
        return role.toUpperCase();
    }
  }

  // Availability display name
  String get availabilityDisplayName {
    switch (availability.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'off-duty':
        return 'Off Duty';
      default:
        return availability.toUpperCase();
    }
  }

  // Create a copy with updated fields
  Staff copyWith({
    int? staffId,
    String? name,
    String? email,
    String? role,
    String? availability,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Staff(
      staffId: staffId ?? this.staffId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      availability: availability ?? this.availability,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Static methods for validation
  static bool isValidRole(String role) {
    final validRoles = ['nurse', 'paramedic', 'security', 'firefighter', 'others'];
    return validRoles.contains(role.toLowerCase());
  }

  static bool isValidAvailability(String availability) {
    final validAvailabilities = ['available', 'busy', 'off-duty'];
    return validAvailabilities.contains(availability.toLowerCase());
  }

  static bool isValidStatus(String status) {
    final validStatuses = ['active', 'inactive'];
    return validStatuses.contains(status.toLowerCase());
  }

  // Get available roles
  static List<String> get availableRoles => ['nurse', 'paramedic', 'security', 'firefighter', 'others'];

  // Get available availability options
  static List<String> get availableAvailabilities => ['available', 'busy', 'off-duty'];

  // Get available status options
  static List<String> get availableStatuses => ['active', 'inactive'];
} 