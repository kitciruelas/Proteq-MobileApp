import 'dart:convert';

class WelfareCheck {
  final int? welfareId;
  final int userId;
  final int emergencyId;
  final String status; // 'SAFE', 'NEEDS_HELP', 'NO_RESPONSE'
  final String? remarks;
  final DateTime? reportedAt;

  WelfareCheck({
    this.welfareId,
    required this.userId,
    required this.emergencyId,
    required this.status,
    this.remarks,
    this.reportedAt,
  });

  Map<String, dynamic> toApiJson() => {
        if (welfareId != null) 'welfare_id': welfareId,
        'user_id': userId,
        'emergency_id': emergencyId,
        'status': status,
        if (remarks != null) 'remarks': remarks,
        if (reportedAt != null) 'reported_at': reportedAt!.toIso8601String(),
      };

  factory WelfareCheck.fromJson(Map<String, dynamic> json) => WelfareCheck(
        welfareId: json['welfare_id'],
        userId: json['user_id'],
        emergencyId: json['emergency_id'],
        status: json['status'] ?? 'NO_RESPONSE',
        remarks: json['remarks'],
        reportedAt: json['reported_at'] != null ? DateTime.tryParse(json['reported_at']) : null,
      );

  static List<WelfareCheck> listFromJson(List<dynamic> data) =>
      data.map((e) => WelfareCheck.fromJson(e)).toList();
} 