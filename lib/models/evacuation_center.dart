import 'dart:math';

class EvacuationCenter {
  final int? centerId;
  final String name;
  final int capacity;
  final int currentOccupancy;
  final String contactPerson;
  final String contactNumber;
  final String status;
  final double lat;
  final double lng;
  final String? updatedAt;

  EvacuationCenter({
    this.centerId,
    required this.name,
    required this.capacity,
    required this.currentOccupancy,
    required this.contactPerson,
    required this.contactNumber,
    required this.status,
    required this.lat,
    required this.lng,
    this.updatedAt,
  });

  factory EvacuationCenter.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }
    return EvacuationCenter(
      centerId: json['center_id'],
      name: json['name'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity'].toString()) ?? 0,
      currentOccupancy: json['current_occupancy'] is int ? json['current_occupancy'] : int.tryParse(json['current_occupancy'].toString()) ?? 0,
      contactPerson: json['contact_person'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      status: json['status'] ?? '',
      lat: json['latitude'] != null
          ? parseDouble(json['latitude'])
          : parseDouble(json['lat']),
      lng: json['longitude'] != null
          ? parseDouble(json['longitude'])
          : parseDouble(json['lng']),
      updatedAt: json['last_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'center_id': centerId,
      'name': name,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
      'status': status,
      'latitude': lat,
      'longitude': lng,
      'last_updated': updatedAt,
    };
  }

  double distanceTo(double userLat, double userLng) {
    const earthRadius = 6371; // km
    double dLat = _deg2rad(userLat - lat);
    double dLng = _deg2rad(userLng - lng);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat)) * cos(_deg2rad(userLat)) *
        sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
} 