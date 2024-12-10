import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/child_provider.dart';
import 'package:parentseye_parent/provider/geofences_provider.dart';
import 'package:parentseye_parent/provider/request_provider.dart';
import 'package:parentseye_parent/widgets/error_dialog.dart';
import 'package:parentseye_parent/widgets/success_dialog.dart';
import 'package:provider/provider.dart';

class PlaceARequest extends StatefulWidget {
  const PlaceARequest({super.key});

  @override
  _PlaceARequestState createState() => _PlaceARequestState();
}

class _PlaceARequestState extends State<PlaceARequest> {
  String? _selectedRequestType;
  String? _selectedChild;
  DateTimeRange? _selectedDateRange;
  String? _reason;
  String? _selectedGeofence;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProvider = Provider.of<ChildProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      childProvider.fetchParentStudentData(authProvider.token!);

      final geofenceProvider =
          Provider.of<GeofenceProvider>(context, listen: false);

      if (childProvider.parentStudentModel?.children.isNotEmpty == true) {
        String deviceId =
            childProvider.parentStudentModel!.children.first.deviceId;
        geofenceProvider.fetchGeofences(deviceId);
      } else {
        print('No children found to fetch geofences');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Place A Request',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundColor, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRequestTypeDropdown(),
                const SizedBox(height: 20),
                _buildChildDropdown(),
                const SizedBox(height: 20),
                if (_selectedRequestType == 'leave')
                  _buildDateRangeSelector(context)
                else if (_selectedRequestType == 'changeRoute')
                  _buildGeofenceDropdown(),
                const SizedBox(height: 20),
                _buildReasonField(),
                const SizedBox(height: 32),
                _isSubmitting
                    ? Center(
                        child: LoadingAnimationWidget.flickr(
                            leftDotColor: Colors.red,
                            rightDotColor: Colors.blue,
                            size: 30))
                    : _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRequestType,
          isExpanded: true,
          icon:
              const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
          items: ['leave', 'changeRoute'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRequestType = newValue!;
              _selectedDateRange = null;
              _selectedGeofence = null;
            });
          },
          hint: Text("Select Request Type",
              style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildChildDropdown() {
    final childProvider = Provider.of<ChildProvider>(context);

    ParentStudentModel? familyData = childProvider.parentStudentModel;
    bool isValidSelection =
        familyData?.children.any((child) => child.childId == _selectedChild) ??
            false;

    if (!isValidSelection) {
      _selectedChild = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedChild,
          isExpanded: true,
          icon:
              const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
          items: familyData?.children.map((StudentDetails child) {
                return DropdownMenuItem<String>(
                  value: child.childId,
                  child: Text(child.childName),
                );
              }).toList() ??
              [],
          onChanged: (String? newValue) {
            setState(() {
              _selectedChild = newValue!;
            });
          },
          hint: Text('Select a child',
              style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: AppColors.primaryColor,
                colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryLightColor),
                buttonTheme:
                    const ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDateRange = picked;
          });
        }
      },
      icon: const Icon(Icons.date_range, color: AppColors.textColor),
      label: Text(
        _selectedDateRange != null
            ? '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}'
            : 'Select Date Range',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildGeofenceDropdown() {
    final geofenceProvider = Provider.of<GeofenceProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGeofence,
          isExpanded: true,
          icon:
              const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
          items: geofenceProvider.geofences.map((geofence) {
            return DropdownMenuItem<String>(
              value: geofence.name,
              child: Text(geofence.name),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGeofence = newValue!;
            });
          },
          hint: Text(
            "Select New Route",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Reason (Required)',
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceColor,
      ),
      style: GoogleFonts.poppins(fontSize: 16),
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          _reason = value;
        });
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requestProvider =
        Provider.of<RequestProvider>(context, listen: false);

    return ElevatedButton(
      onPressed: requestProvider.isLoading
          ? null
          : () async {
              if (_selectedChild == null ||
                  (_selectedRequestType == 'leave' &&
                      _selectedDateRange == null) ||
                  (_selectedRequestType == 'changeRoute' &&
                      _selectedGeofence == null) ||
                  _reason == null ||
                  _reason!.trim().isEmpty) {
                ErrorDialog.showErrorDialog(
                  context,
                  'Please fill in all required fields, including reason.',
                );
                return;
              }

              setState(() {
                _isSubmitting = true;
              });

              try {
                Map<String, dynamic> requestBody;
                if (_selectedRequestType == 'leave') {
                  requestBody = {
                    'requestType': _selectedRequestType!,
                    'startDate': _selectedDateRange!.start.toIso8601String(),
                    'endDate': _selectedDateRange!.end.toIso8601String(),
                    'childId': _selectedChild!,
                    'reason': _reason,
                  };
                } else {
                  requestBody = {
                    'requestType': _selectedRequestType!,
                    'childId': _selectedChild!,
                    'reason': _reason,
                    'newRoute': _selectedGeofence,
                  };
                }

                await requestProvider.placeRequest(
                  requestBody: requestBody,
                  token: authProvider.token!,
                );

                setState(() {
                  _isSubmitting = false;
                });

                SuccessDialog.showSuccessDialog(
                    context, 'Your request has been submitted successfully!');
              } catch (error) {
                setState(() {
                  _isSubmitting = false;
                });

                ErrorDialog.showErrorDialog(
                    context, 'Failed to submit request. Please try again.');
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: requestProvider.isLoading
          ? LoadingAnimationWidget.flickr(
              leftDotColor: Colors.red, rightDotColor: Colors.blue, size: 30)
          : Text(
              'Submit Request',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
    );
  }
}
