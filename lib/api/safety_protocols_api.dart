
import '../models/safety_protocol.dart';
import 'api_client.dart';
import 'package:flutter/foundation.dart';

class SafetyProtocolsApi {
   static final String _baseUrl = kIsWeb
      ? 'http://localhost/api'
      : 'http://192.168.0.102/api';

  // Get all safety protocols
  static Future<Map<String, dynamic>> getAllProtocols() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php',
        method: 'GET',
    );
  }

  // Get protocols by type
  static Future<Map<String, dynamic>> getProtocolsByType(String type) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=get_by_type&type=$type',
      method: 'GET',
    );
  }

  // Get protocol by ID
  static Future<Map<String, dynamic>> getProtocolById(int protocolId) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=get_by_id&id=$protocolId',
      method: 'GET',
    );
  }

  // Search protocols
  static Future<Map<String, dynamic>> searchProtocols(String query) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=search&query=$query',
      method: 'GET',
    );
  }

  // Create new safety protocol
  static Future<Map<String, dynamic>> createProtocol(SafetyProtocol protocol) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=create',
      method: 'POST',
      body: protocol.toApiJson(),
    );
  }

  // Update safety protocol
  static Future<Map<String, dynamic>> updateProtocol(int protocolId, SafetyProtocol protocol) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=update&id=$protocolId',
      method: 'PUT',
      body: protocol.toApiJson(),
    );
  }

  // Delete safety protocol
  static Future<Map<String, dynamic>> deleteProtocol(int protocolId) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=delete&id=$protocolId',
      method: 'DELETE',
    );
  }

  // Toggle protocol active status
  static Future<Map<String, dynamic>> toggleProtocolStatus(int protocolId, bool isActive) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=toggle_status&id=$protocolId',
      method: 'POST',
      body: {'is_active': isActive},
    );
  }

  // Get protocol statistics
  static Future<Map<String, dynamic>> getProtocolStatistics() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=stats',
      method: 'GET',
    );
  }

  // Get emergency contacts
  static Future<Map<String, dynamic>> getEmergencyContacts() async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=emergency_contacts',
      method: 'GET',
    );
  }

  // Update emergency contacts
  static Future<Map<String, dynamic>> updateEmergencyContacts(Map<String, String> contacts) async {
    return await ApiClient.authenticatedCall(
      endpoint: '/controller/SafetyProtocols.php?action=update_emergency_contacts',
      method: 'POST',
      body: contacts,
    );
  }
}