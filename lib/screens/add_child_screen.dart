import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/devices_register_model.dart';
import 'package:parentseye_parent/models/geofencing_model.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/child_provider.dart';
import 'package:parentseye_parent/provider/devices_provider.dart';
import 'package:parentseye_parent/provider/geofences_provider.dart';
import 'package:parentseye_parent/provider/school_provider.dart';
import 'package:provider/provider.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController rollnoController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  String _selectedGender = 'male';
  String? selectedClass;
  int? age;
  Geofence? selectedGeofence;
  DeviceRegModel? selectedDevice;
  String? selectedSchoolName;
  String? selectedBranchName;
  final List<String> classOptions =
      List.generate(10, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchGeofences();
      Provider.of<SchoolProvider>(context, listen: false).fetchSchools();
      fetchDevicesWithSchoolInfo();
    });
  }

  void fetchDevicesWithSchoolInfo() {
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    if (childProvider.parentStudentModel != null &&
        childProvider.parentStudentModel!.children.isNotEmpty) {
      final firstChild = childProvider.parentStudentModel!.children.first;
      selectedSchoolName = firstChild.schoolName;
      selectedBranchName = firstChild.branchName;

      deviceProvider.fetchDevices(selectedSchoolName!, selectedBranchName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Child',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildTextField(childNameController, "Child's name", Icons.person),
            const SizedBox(height: 15),
            _buildGenderSelection(),
            const SizedBox(height: 15),
            _buildDatePicker(),
            const SizedBox(height: 15),
            if (age != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Age: $age years',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            _buildDropdown("Class", classOptions, selectedClass,
                (String? newValue) {
              setState(() {
                selectedClass = newValue;
              });
            }),
            const Gap(15),
            _buildDeviceDropdown(),
            Gap(15),
            if (selectedDevice != null) _buildGeofenceDropdown(),
            const Gap(15),
            _buildTextField(rollnoController, "Roll No",
                Icons.format_list_numbered_rtl_rounded),
            const SizedBox(height: 15),
            _buildSectionTextField(),
            const SizedBox(height: 25),
            Consumer<ChildProvider>(builder: (context, childProvider, child) {
              return ElevatedButton(
                onPressed: childProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() &&
                            selectedClass != null &&
                            dobController.text.isNotEmpty) {
                          String? error = await childProvider.addChild(
                            token: authProvider.token!,
                            childName: childNameController.text,
                            childAge: age.toString(),
                            className: selectedClass!,
                            rollno: rollnoController.text,
                            section: sectionController.text,
                            // schoolName: selectedSchool!.schoolName,
                            gender: _selectedGender,
                            dateOfBirth: dobController.text,
                            pickupPoint: selectedGeofence!.name,
                            deviceId: selectedDevice!.deviceId.toString(),
                            deviceName: selectedDevice!.deviceName,
                            // branchName: selectedBranch!,
                          );

                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Child added successfully')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error adding child: $error')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all fields')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.primaryColor),
                child: childProvider.isLoading
                    ? LoadingAnimationWidget.flickr(
                        leftDotColor: Colors.red,
                        rightDotColor: Colors.blue,
                        size: 30)
                    : Text(
                        'Add Child',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTextField() {
    return TextFormField(
      controller: sectionController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.group_work_rounded),
        hintText: "Section",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: AppColors.backgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      maxLength: 1,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
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
                Icon(Icons.devices, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Text('Select Bus',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade600)),
                const Text(' *',
                    style: TextStyle(color: Colors.red, fontSize: 20)),
              ],
            ),
            value: selectedDevice,
            isExpanded: true,
            items: deviceProvider.devices.map((DeviceRegModel device) {
              return DropdownMenuItem<DeviceRegModel>(
                value: device,
                child: Text(device.deviceName,
                    style: GoogleFonts.poppins(fontSize: 14)),
              );
            }).toList(),
            onChanged: (DeviceRegModel? newValue) {
              setState(() {
                selectedDevice = newValue;
                selectedGeofence = null;
              });
              if (newValue != null) {
                Provider.of<GeofenceProvider>(context, listen: false)
                    .fetchGeofences(newValue.deviceId.toString());
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a Bus';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
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
                Text('Select Bus Stop',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade600)),
                const Text(' *',
                    style: TextStyle(color: Colors.red, fontSize: 20)),
              ],
            ),
            value: selectedGeofence,
            isExpanded: true,
            items: geofenceProvider.geofences.map((Geofence geofence) {
              return DropdownMenuItem<Geofence>(
                value: geofence,
                child: Text(geofence.name,
                    style: GoogleFonts.poppins(fontSize: 14)),
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

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Male', style: GoogleFonts.poppins()),
                value: 'male',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text('Female', style: GoogleFonts.poppins()),
                value: 'female',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? value,
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      hint: Text(hint, style: GoogleFonts.poppins()),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
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
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today),
        hintText: "Date of Birth",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Date of Birth is required';
        }
        return null;
      },
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
}
