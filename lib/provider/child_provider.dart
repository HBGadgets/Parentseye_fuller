import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';

class ChildProvider with ChangeNotifier {
  ParentStudentModel? _parentStudentModel;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  ParentStudentModel? get parentStudentModel => _parentStudentModel;

  Future<void> fetchParentStudentData(String token) async {
    final url = Uri.parse(ApiConstants.getChildData);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        log(responseData.toString());
        if (responseData['children'] != null) {
          _parentStudentModel = ParentStudentModel.fromJson({
            'parent': _parentStudentModel?.parentDetails.toJson() ??
                {'parentName': '', 'email': '', 'phone': '', 'parentId': ''},
            'children': responseData['children'] as List<dynamic>,
          });
          notifyListeners();
        } else {
          throw Exception('Children info is missing in the response');
        }
      } else {
        throw Exception(
          'Failed to fetch family data: ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      log('Error fetching family data: $e');
    }
  }

  Future<String?> addChild({
    required String token,
    required String childName,
    required String childAge,
    required String className,
    required String rollno,
    required String section,
    required String gender,
    required String dateOfBirth,
    required String pickupPoint,
    required String deviceId,
    required String deviceName,
  }) async {
    _setLoading(true);
    final url = Uri.parse(ApiConstants.addChild);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'childName': childName,
          'childAge': childAge,
          'class': className,
          'rollno': rollno,
          'section': section,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'pickupPoint': pickupPoint,
          'deviceId': deviceId,
          'deviceName': deviceName,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || responseData['success'] == true) {
        await fetchParentStudentData(token);
        return null;
      } else {
        return responseData['message'] ?? 'Failed to add child';
      }
    } catch (e) {
      log("Add Child Error: $e");
      return 'Failed to add child: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> updateChild({
    required String token,
    required String childId,
    required String childName,
    required String childAge,
    required String className,
    required String rollno,
    required String section,
    required String schoolName,
    required String gender,
    required String dateOfBirth,
  }) async {
    _setLoading(true);
    final url = Uri.parse(ApiConstants.updateChildWithId(childId));
    try {
      final response = await http.put(
        url,
        body: jsonEncode({
          'childName': childName,
          'childAge': childAge,
          'class': className,
          'rollno': rollno,
          'section': section,
          'schoolName': schoolName,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || responseData['success'] == true) {
        await fetchParentStudentData(token);
        return null;
      } else {
        return responseData['message'] ?? 'Failed to update child';
      }
    } catch (e) {
      log("Update Child Error: $e");
      return 'Failed to update child: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
