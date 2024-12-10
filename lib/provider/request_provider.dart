import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';
import 'package:parentseye_parent/models/request_history_model.dart';

class RequestProvider with ChangeNotifier {
  bool _isLoading = false;
  List<RequestHistoryModel> _requests = [];

  List<RequestHistoryModel> get requests => _requests;
  bool get isLoading => _isLoading;

  Future<void> placeRequest({
    required Map<String, dynamic> requestBody,
    required String token,
  }) async {
    _setLoading(true);
    const url = ApiConstants.request;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 201) {
        log(response.body);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRequestHistory(String token) async {
    _setLoading(true);
    final url = Uri.parse(ApiConstants.requestHistory);
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
        final Map<String, dynamic> data = json.decode(response.body);
        _requests = (data['requests'] as List)
            .map((item) => RequestHistoryModel.fromJson(item))
            .toList();

        _requests.sort((a, b) {
          final DateTime dateA = DateTime.parse(a.requestDate)
              .toUtc()
              .add(const Duration(hours: 5, minutes: 30));
          final DateTime dateB = DateTime.parse(b.requestDate)
              .toUtc()
              .add(const Duration(hours: 5, minutes: 30));
          return dateB.compareTo(dateA);
        });

        notifyListeners();
      } else {
        throw Exception('Failed to load request history');
      }
    } catch (error) {
      log('Error fetching request history: $error');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
