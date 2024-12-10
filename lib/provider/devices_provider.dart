import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';

import '../models/devices_register_model.dart';

class DeviceProvider with ChangeNotifier {
  List<DeviceRegModel> _devices = [];
  List<DeviceRegModel> get devices => _devices;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchDevices(String schoolName, String branchName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.getSchoolDevices}?schoolName=$schoolName&branchName=$branchName'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        _devices = (data['devices'] as List)
            .map((json) => DeviceRegModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      print('Error fetching devices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
