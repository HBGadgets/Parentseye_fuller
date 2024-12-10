import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';

import '../models/geofencing_model.dart';

class GeofenceProvider with ChangeNotifier {
  List<Geofence> _geofences = [];
  List<Geofence> get geofences => _geofences;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _deviceId;
  String? get deviceId => _deviceId;

  void setDeviceId(String id) {
    _deviceId = id;
  }

  Timer? _debounce;

  Future<void> fetchGeofences(String deviceId) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 5), () async {
      _isLoading = true;
      _deviceId = deviceId;
      notifyListeners();

      try {
        final response = await http.get(
          Uri.parse('${ApiConstants.geofencesUrl}?deviceId=$deviceId'),
        );

        if (response.statusCode == 200) {
          log("Geofence Data: ${response.body}");
          Map<String, dynamic> data = json.decode(response.body);
          List<dynamic> geofencesData = data['geofences'];
          _geofences =
              geofencesData.map((json) => Geofence.fromJson(json)).toList();
        } else {
          print(
              'Failed to load geofences. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('An error occurred while fetching geofences: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> updateGeofenceStatus(
    String geofenceId,
    bool isCrossed,
    String? arrivalTime,
    String? departureTime,
  ) async {
    final url = '${ApiConstants.geofenceIsCrossed}/?geofenceId=$geofenceId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'isCrossed': isCrossed,
          'arrivalTime': arrivalTime,
          'departureTime': departureTime,
        }),
      );

      if (response.statusCode == 200) {
        await fetchGeofences(_deviceId!);
      } else {
        print(
          'Failed to update geofence status. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updating geofence status: $e');
    }
  }
}
