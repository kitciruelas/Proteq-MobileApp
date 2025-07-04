import '../api/incident_report_api.dart';
import '../models/incident_report.dart';

class IncidentReportService {
  // Submit a new incident report
  static Future<Map<String, dynamic>> submitReport(IncidentReport report) async {
    try {
      final result = await IncidentReportApi.submitIncidentReport(report);
      
      // Check for authentication errors
      if (result['success'] == false && 
          (result['message']?.toString().toLowerCase().contains('authentication') == true ||
           result['message']?.toString().toLowerCase().contains('login') == true)) {
        return {
          'success': false,
          'message': 'Please log in again to submit your report.',
          'requiresAuth': true,
        };
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit report: $e',
      };
    }
  }

  // Filter reports by status
  static List<IncidentReport> filterReportsByStatus(List<IncidentReport> reports, String status) {
    return reports.where((report) => report.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Filter reports by priority
  static List<IncidentReport> filterReportsByPriority(List<IncidentReport> reports, String priority) {
    return reports.where((report) => report.priorityLevel.toLowerCase() == priority.toLowerCase()).toList();
  }

  // Get reports that need immediate attention (Critical priority or In Danger safety status)
  static List<IncidentReport> getUrgentReports(List<IncidentReport> reports) {
    return reports.where((report) => 
      report.priorityLevel.toLowerCase() == 'critical' || 
      report.safetyStatus.toLowerCase() == 'in danger'
    ).toList();
  }
} 