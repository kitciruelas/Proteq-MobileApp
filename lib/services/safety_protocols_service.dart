import 'dart:convert';

import '../api/safety_protocols_api.dart';
import '../models/safety_protocol.dart';

class SafetyProtocolsService {
  // Get all safety protocols
  static Future<List<SafetyProtocol>> getAllProtocols() async {
    try {
      final result = await SafetyProtocolsApi.getAllProtocols();
      print('Raw API result: ' + result.toString()); // Debug print
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> protocolsData = result['data'];
        return protocolsData.map((json) => SafetyProtocol.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error in getAllProtocols: ' + e.toString()); // Debug print
      return [];
    }
  }

  // Get protocols by type
  static Future<List<SafetyProtocol>> getProtocolsByType(String type) async {
    try {
      final result = await SafetyProtocolsApi.getProtocolsByType(type);
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> protocolsData = result['data'];
        return protocolsData.map((json) => SafetyProtocol.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get protocol by ID
  static Future<SafetyProtocol?> getProtocolById(int protocolId) async {
    try {
      final result = await SafetyProtocolsApi.getProtocolById(protocolId);
      if (result['success'] == true && result['data'] != null) {
        return SafetyProtocol.fromJson(result['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search protocols
  static Future<List<SafetyProtocol>> searchProtocols(String query) async {
    try {
      final result = await SafetyProtocolsApi.searchProtocols(query);
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> protocolsData = result['data'];
        return protocolsData.map((json) => SafetyProtocol.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Filter protocols by type
  static List<SafetyProtocol> filterProtocolsByType(List<SafetyProtocol> protocols, String type) {
    if (type.toLowerCase() == 'all') {
      return protocols;
    }
    return protocols.where((protocol) => protocol.type.toLowerCase() == type.toLowerCase()).toList();
  }

  // Filter protocols by search query
  static List<SafetyProtocol> filterProtocolsBySearch(List<SafetyProtocol> protocols, String query) {
    if (query.isEmpty) {
      return protocols;
    }
    return protocols.where((protocol) => 
      protocol.title.toLowerCase().contains(query.toLowerCase()) ||
      protocol.description.toLowerCase().contains(query.toLowerCase()) ||
      protocol.type.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get active protocols only
  static List<SafetyProtocol> getActiveProtocols(List<SafetyProtocol> protocols) {
    return protocols.where((protocol) => protocol.isActive).toList();
  }

  // Sort protocols by priority
  static List<SafetyProtocol> sortProtocolsByPriority(List<SafetyProtocol> protocols) {
    final sorted = List<SafetyProtocol>.from(protocols);
    sorted.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
    return sorted;
  }

  // Sort protocols by creation date (newest first)
  static List<SafetyProtocol> sortProtocolsByDate(List<SafetyProtocol> protocols) {
    final sorted = List<SafetyProtocol>.from(protocols);
    sorted.sort((a, b) => (b.createdAt ?? DateTime(1900)).compareTo(a.createdAt ?? DateTime(1900)));
    return sorted;
  }
} 