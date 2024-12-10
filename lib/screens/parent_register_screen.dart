import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/devices_register_model.dart';
import 'package:parentseye_parent/models/geofencing_model.dart';
import 'package:parentseye_parent/models/school_model.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/devices_provider.dart';
import 'package:parentseye_parent/provider/geofences_provider.dart';
import 'package:parentseye_parent/provider/school_provider.dart';
import 'package:parentseye_parent/screens/help_support.dart';
import 'package:parentseye_parent/screens/parent_login_screen.dart';
import 'package:parentseye_parent/services/notification_services.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final NotificationServices _notificationServices = NotificationServices();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController rollnoController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String _selectedGender = 'male';
  String? selectedClass;
  int? age;
  DeviceRegModel? selectedDevice;
  Geofence? selectedGeofence;
  School? selectedSchool;
  Branch? selectedBranch;

  @override
  void initState() {
    super.initState();
    _notificationServices.initNotification(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchGeofences();
      Provider.of<DeviceProvider>(context, listen: false).fetchDevices('', '');
      Provider.of<SchoolProvider>(context, listen: false).fetchSchools();
    });
  }

  final List<String> classOptions =
      List.generate(10, (index) => (index + 1).toString());

  Widget _buildSchoolDropdown() {
    return Consumer<SchoolProvider>(
      builder: (context, schoolProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: DropdownButtonFormField<School>(
            hint: Row(
              children: [
                Icon(Icons.school, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Text(
                  'Select School',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            value: selectedSchool,
            isExpanded: true,
            items: schoolProvider.schools.map((School school) {
              return DropdownMenuItem<School>(
                value: school,
                child: Text(
                  school.schoolName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (School? newValue) {
              setState(() {
                selectedSchool = newValue;
                selectedBranch = null;
                selectedDevice = null;
                schoolNameController.text = newValue?.schoolName ?? '';
              });
              Provider.of<DeviceProvider>(context, listen: false)
                  .fetchDevices('', '');
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a school';
              }
              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: schoolProvider.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: LoadingAnimationWidget.flickr(
                          leftDotColor: Colors.red,
                          rightDotColor: Colors.blue,
                          size: 30))
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBranchDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: DropdownButtonFormField<Branch>(
        hint: Row(
          children: [
            Icon(Icons.location_city, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Text(
              'Select Branch',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 20)),
          ],
        ),
        value: selectedBranch,
        isExpanded: true,
        items: selectedSchool?.branches.map((Branch branch) {
              return DropdownMenuItem<Branch>(
                value: branch,
                child: Text(
                  branch.branchName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              );
            }).toList() ??
            [],
        onChanged: (Branch? newValue) {
          setState(() {
            selectedBranch = newValue;
            selectedDevice = null;
          });
          if (selectedSchool != null && newValue != null) {
            Provider.of<DeviceProvider>(context, listen: false).fetchDevices(
              selectedSchool!.schoolName,
              newValue.branchName,
            );
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a branch';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDeviceDropdown() {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: DropdownButtonFormField<DeviceRegModel>(
            hint: Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Text(
                  'Select Bus',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            value: selectedDevice,
            isExpanded: true,
            items: deviceProvider.devices.map((DeviceRegModel device) {
              return DropdownMenuItem<DeviceRegModel>(
                value: device,
                child: Text(
                  device.deviceName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (DeviceRegModel? newValue) {
              setState(() {
                selectedDevice = newValue;
                selectedGeofence = null;
              });
              if (newValue != null) {
                Provider.of<GeofenceProvider>(context, listen: false)
                    .fetchGeofences(newValue.deviceId);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a Bus';
              }
              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: deviceProvider.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: LoadingAnimationWidget.flickr(
                          leftDotColor: Colors.red,
                          rightDotColor: Colors.blue,
                          size: 30))
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeofenceDropdown() {
    return Consumer<GeofenceProvider>(
      builder: (context, geofenceProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: DropdownButtonFormField<Geofence>(
            hint: Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Text(
                  'Select Bus Stop',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ],
            ),
            value: selectedGeofence,
            isExpanded: true,
            items: geofenceProvider.geofences.map((Geofence geofence) {
              return DropdownMenuItem<Geofence>(
                value: geofence,
                child: Text(
                  geofence.name,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (Geofence? newValue) {
              setState(() {
                selectedGeofence = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a Bus Stop';
              }
              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: geofenceProvider.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: LoadingAnimationWidget.flickr(
                          leftDotColor: Colors.red,
                          rightDotColor: Colors.blue,
                          size: 30))
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 220,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.asset("assets/parentseye_logo.png"),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Welcome to ParentsEye",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Text(
                            "Register your child",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            childNameController,
                            "Child's name",
                            Icons.person,
                          ),
                          const SizedBox(height: 15),
                          _buildGenderSelection(),
                          const SizedBox(height: 15),
                          _buildDatePicker(),
                          if (age != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                'Age: $age years',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const Gap(15),
                          _buildDropdown(
                            "Class",
                            classOptions,
                            selectedClass,
                            (String? newValue) {
                              setState(() {
                                selectedClass = newValue;
                              });
                            },
                            Icons.class_,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            rollnoController,
                            "Roll No",
                            Icons.format_list_numbered_rtl_rounded,
                          ),
                          const Gap(15),
                          _buildTextField(
                            sectionController,
                            "Section",
                            Icons.group_work_rounded,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              UpperCaseTextFormatter(),
                            ],
                          ),
                          const Gap(15),
                          _buildSchoolDropdown(),
                          const Gap(15),
                          if (selectedSchool != null) _buildBranchDropdown(),
                          const Gap(15),
                          if (selectedBranch != null) _buildDeviceDropdown(),
                          Gap(15),
                          if (selectedDevice != null) _buildGeofenceDropdown(),
                          const Gap(15),
                          _buildTextField(
                            parentNameController,
                            "Parent name",
                            Icons.person,
                          ),
                          const Gap(15),
                          _buildTextField(
                            phoneController,
                            "Phone number",
                            Icons.phone,
                          ),
                          const SizedBox(height: 25),
                          _buildTextField(
                            emailController,
                            "Parent's Username",
                            Icons.email,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            passwordController,
                            "Password",
                            Icons.lock,
                            isPassword: true,
                          ),
                          const Gap(15),
                          _buildTextField(
                            cpasswordController,
                            "Confirm password",
                            Icons.lock_outline_rounded,
                            isPassword: true,
                          ),
                          const Gap(15),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate() &&
                                            selectedClass != null &&
                                            dobController.text.isNotEmpty &&
                                            selectedDevice != null &&
                                            selectedGeofence != null) {
                                          try {
                                            String? fcmToken =
                                                await _notificationServices
                                                    .getFCMToken();
                                            if (fcmToken == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Failed to get FCM token')),
                                              );
                                              return;
                                            }
                                            final result =
                                                await Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).register(
                                              deviceId: selectedDevice!.deviceId
                                                  .toString(),
                                              email:
                                                  emailController.text.trim(),
                                              password: passwordController.text
                                                  .trim(),
                                              childName:
                                                  childNameController.text,
                                              childAge: age.toString(),
                                              className: selectedClass!,
                                              rollno: rollnoController.text,
                                              section: sectionController.text,
                                              schoolName:
                                                  selectedSchool!.schoolName,
                                              parentName:
                                                  parentNameController.text,
                                              phone: phoneController.text,
                                              gender: _selectedGender,
                                              dateOfBirth: dobController.text,
                                              deviceName:
                                                  selectedDevice!.deviceName,
                                              pickupPoint:
                                                  selectedGeofence!.name,
                                              branchName:
                                                  selectedBranch!.branchName,
                                              fcmToken: fcmToken,
                                            );
                                            if (result == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Registration successful')),
                                              );
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ParentalLogin()),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(content: Text(result)),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'An error occurred: $e')),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Please fill all fields')),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? LoadingAnimationWidget.flickr(
                                        leftDotColor: Colors.red,
                                        rightDotColor: Colors.blue,
                                        size: 30)
                                    : Text(
                                        'Register',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HelpAndSupportScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Need Help?",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ParentalLogin(),
                                  ),
                                );
                              },
                              child: Text(
                                "Already have an account? Login",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
            setState(() {
              dobController.text = formattedDate;
              age = calculateAge(pickedDate);
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date of Birth is required';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
          hintText: "Date of Birth",
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: const Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      ),
    );
  }

  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon,
      {bool isPassword = false,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        inputFormatters: inputFormatters ??
            (hintText == "Phone number" ? [PhoneNumberFormatter()] : null),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: const Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Gender',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Male', style: GoogleFonts.poppins(fontSize: 14)),
                  value: 'male',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppColors.primaryColor,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title:
                      Text('Female', style: GoogleFonts.poppins(fontSize: 14)),
                  value: 'female',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: DropdownButtonFormField<String>(
        hint: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Text(
              hint,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 20)),
          ],
        ),
        value: value,
        isExpanded: true,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class LengthLimitingTextInputFormatter extends TextInputFormatter {
  LengthLimitingTextInputFormatter(this.maxLength)
      : assert(maxLength == null || maxLength > 0);

  final int? maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null && newValue.text.length > maxLength!) {
      return oldValue;
    }
    return newValue;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length &&
        oldValue.text.startsWith('+91')) {
      if (newValue.text.length <= 3) {
        return const TextEditingValue(
          text: '+91',
          selection: TextSelection.collapsed(offset: 3),
        );
      }
      return newValue;
    }

    String text = newValue.text;
    text = text.replaceAll(RegExp(r'[^\d]'), '');
    if (!text.startsWith('91')) {
      text = '91$text';
    }
    text = text.substring(0, math.min(text.length, 12));
    final formattedText = '+$text';
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
