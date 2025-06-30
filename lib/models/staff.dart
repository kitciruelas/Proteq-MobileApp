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
    return Staff(
      staffId: json['staff_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      availability: json['availability'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'name': name,
      'email': email,
      'role': role,
      'availability': availability,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 