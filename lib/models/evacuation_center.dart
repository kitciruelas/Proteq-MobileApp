class EvacuationCenter {
  final int? centerId;
  final String name;
  final String capacity;
  final String contact;
  final String status;
  final double lat;
  final double lng;
  final String? address;
  final String? createdAt;
  final String? updatedAt;

  EvacuationCenter({
    this.centerId,
    required this.name,
    required this.capacity,
    required this.contact,
    required this.status,
    required this.lat,
    required this.lng,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory EvacuationCenter.fromJson(Map<String, dynamic> json) {
    return EvacuationCenter(
      centerId: json['center_id'],
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? '',
      contact: json['contact'] ?? '',
      status: json['status'] ?? '',
      lat: json['lat'] is double ? json['lat'] : double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: json['lng'] is double ? json['lng'] : double.tryParse(json['lng'].toString()) ?? 0.0,
      address: json['address'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'center_id': centerId,
      'name': name,
      'capacity': capacity,
      'contact': contact,
      'status': status,
      'lat': lat,
      'lng': lng,
      'address': address,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 