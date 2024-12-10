import 'package:google_maps_flutter/google_maps_flutter.dart';

class Geofence {
  final String id;
  final String name;
  final LatLng center;
  final double radius;
  final bool isCrossed;
  final String busStopTime;
  final String? arrivalTime;
  final String? departureTime;

  Geofence({
    required this.id,
    required this.name,
    required this.center,
    required this.radius,
    required this.isCrossed,
    required this.busStopTime,
    this.arrivalTime,
    this.departureTime,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as String;
    final areaComponents =
        area.replaceAll('Circle(', '').replaceAll(')', '').split(', ');
    final centerCoords = areaComponents[0].split(' ');
    return Geofence(
      id: json['_id'],
      name: json['name'],
      center: LatLng(
        double.parse(centerCoords[0]),
        double.parse(centerCoords[1]),
      ),
      radius: double.parse(areaComponents[1]),
      isCrossed: json['isCrossed'],
      busStopTime: json['busStopTime'] ?? '',
      arrivalTime: json['arrivalTime'],
      departureTime: json['departureTime'],
    );
  }
}
