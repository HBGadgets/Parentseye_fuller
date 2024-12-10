import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:provider/provider.dart';

import '../constants/api_constants.dart';
import '../models/devices_model.dart';
import '../models/geofencing_model.dart';
import '../models/positions_model.dart';
import '../provider/geofences_provider.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class TrackingProvider with ChangeNotifier {
  Device? _device;
  List<PositionsModel> _positions = [];
  Timer? _timer;
  bool _isLoading = false;
  String? _error;
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration timeoutDuration = Duration(seconds: 15);

  LatLng? _currentAnimatedPosition;
  double _currentAnimatedBearing = 0.0;
  Timer? _animationTimer;
  static const int animationSteps = 60;
  static const Duration animationDuration = Duration(milliseconds: 1000);

  LatLng? get currentAnimatedPosition => _currentAnimatedPosition;
  double get currentAnimatedBearing => _currentAnimatedBearing;
  Device? get device => _device;
  List<PositionsModel> get positions => _positions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  StudentDetails? _studentDetails;

  final String _username = 'schoolmaster';
  final String _password = '123456';

  String _basicAuth() {
    String credentials = '$_username:$_password';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  Future<void> fetchDevice(StudentDetails studentDetails) async {
    if (_isLoading) return;

    _studentDetails = studentDetails;
    _isLoading = true;
    _error = null;
    _retryCount = 0;
    notifyListeners();

    while (_retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse(
              '${ApiConstants.devicesUrl}?deviceId=${studentDetails.deviceId}'),
          headers: {'Authorization': _basicAuth()},
        ).timeout(timeoutDuration);

        if (response.statusCode == 200) {
          print("Devices Response:${response.body}");
          List<dynamic> data = json.decode(response.body);
          if (data.isNotEmpty) {
            _device = Device.fromJson(data[0]);
            _error = null;
            await fetchPositions();
            _isLoading = false;
            notifyListeners();
            return;
          } else {
            throw NetworkException('No device data found');
          }
        } else {
          throw NetworkException('Server returned ${response.statusCode}');
        }
      } catch (e) {
        _retryCount++;
        if (_retryCount >= maxRetries) {
          _error = 'Failed to fetch device data: ${e.toString()}';
          _isLoading = false;
          notifyListeners();
          return;
        }
        await Future.delayed(Duration(seconds: pow(2, _retryCount).toInt()));
      }
    }
  }

  Future<void> fetchPositions() async {
    if (_studentDetails == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.positionsUrl}?deviceId=${_studentDetails!.deviceId}'),
        headers: {'Authorization': _basicAuth()},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        print("Positions Response:${response.body}");
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          List<PositionsModel> newPositions =
              data.map((json) => PositionsModel.fromJson(json)).toList();

          if (_positions.isEmpty || newPositions.last != _positions.last) {
            _positions = newPositions;
            _startAnimation();
          }
          _error = null;
        } else {
          _error = 'No position data available';
        }
      } else {
        _error = 'Failed to load positions: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error updating positions: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  void _startAnimation() {
    if (_positions.isEmpty) return;

    _animationTimer?.cancel();

    PositionsModel targetPosition = _positions.last;
    LatLng targetLatLng =
        LatLng(targetPosition.latitude, targetPosition.longitude);

    if (_currentAnimatedPosition == null) {
      _currentAnimatedPosition = targetLatLng;
      _currentAnimatedBearing = targetPosition.course;
      notifyListeners();
      return;
    }

    LatLng startLatLng = _currentAnimatedPosition!;
    double startBearing = _currentAnimatedBearing;
    double targetBearing = targetPosition.course;
    double bearingDiff = targetBearing - startBearing;
    if (bearingDiff > 180) bearingDiff -= 360;
    if (bearingDiff < -180) bearingDiff += 360;

    int step = 0;
    _animationTimer = Timer.periodic(
      Duration(
          milliseconds:
              (animationDuration.inMilliseconds / animationSteps).round()),
      (timer) {
        step++;

        if (step >= animationSteps) {
          _currentAnimatedPosition = targetLatLng;
          _currentAnimatedBearing = targetBearing;
          timer.cancel();
        } else {
          double progress = step / animationSteps;
          progress = _smoothStep(progress);

          _currentAnimatedPosition = LatLng(
              startLatLng.latitude +
                  (targetLatLng.latitude - startLatLng.latitude) * progress,
              startLatLng.longitude +
                  (targetLatLng.longitude - startLatLng.longitude) * progress);

          _currentAnimatedBearing = startBearing + bearingDiff * progress;
        }

        notifyListeners();
      },
    );
  }

  double _smoothStep(double x) {
    return x * x * (3 - 2 * x);
  }

  void startTracking(BuildContext context) {
    _timer?.cancel();

    fetchPositions().then((_) {
      if (_error == null) {
        checkGeofenceStatus(context);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await fetchPositions();
      if (_error == null) {
        checkGeofenceStatus(context);
      }
    });
  }

  void checkGeofenceStatus(BuildContext context) {
    if (_positions.isEmpty) return;

    final geofenceProvider =
        Provider.of<GeofenceProvider>(context, listen: false);
    final geofences = geofenceProvider.geofences;
    final currentPosition = _positions.last;

    for (var geofence in geofences) {
      bool isInside = _isPositionInsideGeofence(currentPosition, geofence);

      if (isInside && !geofence.isCrossed) {
        String arrivalTime = DateFormat('HH:mm:ss').format(DateTime.now());
        geofenceProvider.updateGeofenceStatus(
            geofence.id, true, arrivalTime, null);
      } else if (!isInside && geofence.isCrossed) {
        String departureTime = DateFormat('HH:mm:ss').format(DateTime.now());
        geofenceProvider.updateGeofenceStatus(
            geofence.id, true, geofence.arrivalTime, departureTime);
      }
    }
  }

  bool _isPositionInsideGeofence(PositionsModel position, Geofence geofence) {
    double distance = _calculateDistance(
      position.latitude,
      position.longitude,
      geofence.center.latitude,
      geofence.center.longitude,
    );
    return distance <= geofence.radius;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String getLastUpdateTimeIndian() {
    if (_positions.isNotEmpty) {
      DateTime lastUpdate = _positions.last.deviceTime;
      final indianOffset = const Duration(hours: 5, minutes: 30);
      DateTime indianTime = lastUpdate.toUtc().add(indianOffset);
      String formattedDate = DateFormat('dd MMM yyyy').format(indianTime);
      String formattedTime = DateFormat('hh:mm a').format(indianTime);

      return "Last updated: $formattedDate at $formattedTime";
    }
    return "Last updated: N/A";
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
}
