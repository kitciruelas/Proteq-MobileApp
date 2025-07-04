class SafetyProtocol {
  final int? protocolId;
  final String type;
  final String title;
  final String description;
  final List<String> steps;
  final String? attachment;
  final String? attachmentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? createdBy;
  final int? priority;

  SafetyProtocol({
    this.protocolId,
    required this.type,
    required this.title,
    required this.description,
    required this.steps,
    this.attachment,
    this.attachmentUrl,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.createdBy,
    this.priority,
  });

  factory SafetyProtocol.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        // Try parsing as ISO8601, else replace space with T
        return DateTime.tryParse(value) ?? DateTime.tryParse(value.replaceFirst(' ', 'T'));
      }
      return null;
    }
    return SafetyProtocol(
      protocolId: parseInt(json['protocol_id']),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      steps: json['steps'] != null 
          ? List<String>.from(json['steps'])
          : [],
      attachment: json['attachment'] ?? json['file_attachment'],
      attachmentUrl: json['attachment_url'],
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by_name'] ?? json['created_by'],
      priority: parseInt(json['priority']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol_id': protocolId,
      'type': type,
      'title': title,
      'description': description,
      'steps': steps,
      'attachment': attachment,
      'attachment_url': attachmentUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'created_by': createdBy,
      'priority': priority,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'steps': steps,
      'attachment': attachment,
      'attachment_url': attachmentUrl,
      'is_active': isActive,
      'priority': priority,
    };
  }

  // Helper method to get icon data based on type
  String getIconName() {
    switch (type.toLowerCase()) {
      case 'fire':
        return 'local_fire_department';
      case 'earthquake':
        return 'place';
      case 'medical':
        return 'medical_services';
      case 'intrusion':
        return 'security';
      case 'general':
        return 'verified_user';
      default:
        return 'info';
    }
  }

  // Helper method to get color based on type
  String getColorName() {
    switch (type.toLowerCase()) {
      case 'fire':
        return 'red';
      case 'earthquake':
        return 'orange';
      case 'medical':
        return 'cyan';
      case 'intrusion':
        return 'purple';
      case 'general':
        return 'green';
      default:
        return 'grey';
    }
  }
} 