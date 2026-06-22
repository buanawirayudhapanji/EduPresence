class CoordinateModel {
  final String? id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  CoordinateModel({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100.0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
    };
  }

  factory CoordinateModel.fromMap(Map<String, dynamic> map) {
    return CoordinateModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radiusMeters: (map['radius_meters'] as num?)?.toDouble() ?? 100.0,
    );
  }
}
