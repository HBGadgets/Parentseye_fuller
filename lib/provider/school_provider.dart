import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';
import 'package:parentseye_parent/models/school_model.dart';

class SchoolProvider extends ChangeNotifier {
  List<School> _schools = [];
  bool _isLoading = false;
  String? _error;

  List<School> get schools => _schools;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSchools() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(ApiConstants.getSchoolUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _schools = (data['schools'] as List)
            .map((schoolJson) => School.fromJson(schoolJson))
            .toList();
      } else {
        _error = 'Failed to load schools';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
