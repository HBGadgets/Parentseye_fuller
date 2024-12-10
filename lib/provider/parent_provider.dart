import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';

import '../models/parent_only_model.dart';

class ParentProvider with ChangeNotifier {
  Parent? _parent;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Parent? get parent => _parent;

  Future<void> fetchAndSetParentData(String token) async {
    _parent = await fetchOnlyParentData(token);
    notifyListeners();
  }

  Future<Parent?> fetchOnlyParentData(String token) async {
    final url = Uri.parse(ApiConstants.getParentData);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log(response.body);
        final responseData = json.decode(response.body);
        if (responseData['parent'] != null) {
          return Parent.fromJson(responseData['parent']);
        }
      }
    } catch (e) {
      log('Error fetching parentOnly data: $e');
    }
    return null;
  }

  Future<String?> updateParent({
    required String token,
    required String parentId,
    required String parentName,
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    final url = Uri.parse(ApiConstants.updateParentWithId(parentId));
    try {
      final response = await http.put(
        url,
        body: jsonEncode({
          'parentName': parentName,
          'email': email,
          'phone': phone,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await fetchAndSetParentData(token);
        return null;
      } else {
        return responseData['message'] ??
            'Failed to update parent: ${response.statusCode}';
      }
    } catch (e) {
      log("Update Parent Error: $e");
      return 'Failed to update parent: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
