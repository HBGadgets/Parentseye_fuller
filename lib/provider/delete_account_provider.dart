import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';

class DeleteAccountProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> deleteAccount(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.deleteAccount),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return null;
      } else {
        return 'Failed to delete account. Please try again.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred: ${e.toString()}';
    }
  }
}
