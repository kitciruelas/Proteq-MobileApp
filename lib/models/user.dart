class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String userType;
  final String email;
  final String department;
  final String college;
  final int status;
  final String? createdAt;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.email,
    required this.department,
    required this.college,
    required this.status,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userType: json['user_type'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      college: json['college'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'email': email,
      'department': department,
      'college': college,
      'status': status,
      'created_at': createdAt,
    };
  }

  String get fullName => '$firstName $lastName';

  bool get isActive => status == 1;

  bool get isStudent => userType.toLowerCase() == 'student';
  bool get isFaculty => userType.toLowerCase() == 'faculty';
  bool get isEmployee => userType.toLowerCase() == 'university_employee';
}
