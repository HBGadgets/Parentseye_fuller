import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/provider/geofences_provider.dart';
import 'package:parentseye_parent/screens/parent_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/geofencing_model.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  bool _fullAccess = false;
  late Future<void> initialized;
  List<Geofence> _geofences = [];
  ParentStudentModel? _parentStudentModel;

  List<Geofence> get geofences => _geofences;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get hasFullAccess => _fullAccess;
  ParentStudentModel? get parentStudentModel => _parentStudentModel;

  AuthProvider() {
    initialized = tryAutoLogin();
  }
  Future<void> fetchGeofences() async {
    if (_parentStudentModel == null || _parentStudentModel!.children.isEmpty) {
      return;
    }

    final geofenceProvider = GeofenceProvider();
    for (var child in _parentStudentModel!.children) {
      await geofenceProvider.fetchGeofences(child.deviceId);
      _geofences.addAll(geofenceProvider.geofences);
    }
    notifyListeners();
  }

  Future<String?> register({
    required String deviceId,
    required String email,
    required String password,
    required String childName,
    required String childAge,
    required String className,
    required String rollno,
    required String section,
    required String schoolName,
    required String parentName,
    required String phone,
    required String gender,
    required String dateOfBirth,
    required String pickupPoint,
    required String deviceName,
    required String branchName,
    required String fcmToken,
  }) async {
    _setLoading(true);

    final url = Uri.parse(ApiConstants.register);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'deviceId': deviceId,
          'email': email,
          'password': password,
          'childName': childName,
          'childAge': childAge,
          'class': className,
          'rollno': rollno,
          'section': section,
          'schoolName': schoolName,
          'parentName': parentName,
          'phone': phone,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'pickupPoint': pickupPoint,
          'deviceName': deviceName,
          'branchName': branchName,
          'fcmToken': fcmToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        log("Registration Success: ${response.body}");
        _token = responseData['token'];
        await _saveToken(_token!);
        return null;
      } else {
        return responseData['message'] ?? 'Registration failed';
      }
    } catch (e) {
      log("Registration Error: ${e.toString()}");
      return 'Registration failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    final url = Uri.parse(ApiConstants.login);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        log("Login response: ${response.body}");
        _token = responseData['token'];
        _fullAccess = responseData['fullAccess'] ?? false;
        if (_token != null) {
          await _saveToken(_token!);
          await _saveFullAccess(_fullAccess);
          return null;
        } else {
          return 'Token is null';
        }
      } else {
        return responseData['message'] ?? 'Login failed';
      }
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void logout(BuildContext context) async {
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Confirm Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.poppins(),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      // Clear all provider state
      _token = null;
      _fullAccess = false;
      _geofences.clear();
      _parentStudentModel = null;
      _isLoading = false;

      // Clear all SharedPreferences data
      await _clearAllData();

      notifyListeners();

      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ParentalLogin()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears ALL SharedPreferences data
  }

  Future<void> tryAutoLogin() async {
    final savedToken = await _getSavedToken();
    if (savedToken != null) {
      _token = savedToken;
      _fullAccess = await _getSavedFullAccess();
      notifyListeners();
    }
  }

  Future<void> _saveFullAccess(bool fullAccess) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('full_access', fullAccess);
  }

  Future<bool> _getSavedFullAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('full_access') ?? true;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
