class PositionsModel {
  final int id;
  final Map<String, dynamic> attributes;
  final int deviceId;
  final String protocol;
  final DateTime serverTime;
  final DateTime deviceTime;
  final DateTime fixTime;
  final bool outdated;
  final bool valid;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double course;
  final String? address;
  final double accuracy;
  final dynamic network;
  final List<int>? geofenceIds;

  PositionsModel({
    required this.id,
    required this.attributes,
    required this.deviceId,
    required this.protocol,
    required this.serverTime,
    required this.deviceTime,
    required this.fixTime,
    required this.outdated,
    required this.valid,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.course,
    this.address,
    required this.accuracy,
    this.network,
    this.geofenceIds,
  });

  factory PositionsModel.fromJson(Map<String, dynamic> json) {
    return PositionsModel(
      id: json['id'],
      attributes: json['attributes'],
      deviceId: json['deviceId'],
      protocol: json['protocol'],
      serverTime: DateTime.parse(json['serverTime']),
      deviceTime: DateTime.parse(json['deviceTime']),
      fixTime: DateTime.parse(json['fixTime']),
      outdated: json['outdated'],
      valid: json['valid'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      altitude: json['altitude'].toDouble(),
      speed: json['speed'].toDouble(),
      course: json['course'].toDouble(),
      address: json['address'],
      accuracy: json['accuracy'].toDouble(),
      network: json['network'],
      geofenceIds: json['geofenceIds'] != null
          ? List<int>.from(json['geofenceIds'])
          : null,
    );
  }
}
