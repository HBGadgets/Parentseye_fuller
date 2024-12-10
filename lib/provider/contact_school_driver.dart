import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';
import 'package:parentseye_parent/models/contact_school_driver.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';

class ContactInfoProvider with ChangeNotifier {
  ContactInfo? _contactInfo;
  ContactInfo? get contactInfo => _contactInfo;

  final AuthProvider authProvider;

  ContactInfoProvider({required this.authProvider});

  Future<void> fetchContactInfo() async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final driverResponse = await http.get(
      Uri.parse(ApiConstants.getDriverMobile),
      headers: headers,
    );
    final schoolResponse = await http.get(
      Uri.parse(ApiConstants.getSchoolMobile),
      headers: headers,
    );

    if (driverResponse.statusCode == 200 && schoolResponse.statusCode == 200) {
      log(driverResponse.body);
      log(schoolResponse.body);
      final driverData = json.decode(driverResponse.body);
      final schoolData = json.decode(schoolResponse.body);

      _contactInfo = ContactInfo(
        driverMobile: driverData['mobile'] ?? '',
        schoolMobile: schoolData['mobile'] ?? '',
      );
      notifyListeners();
    } else {
      throw Exception('Failed to load contact information');
    }
  }
}
