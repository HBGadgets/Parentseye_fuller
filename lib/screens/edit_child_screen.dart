import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/child_provider.dart';
import 'package:provider/provider.dart';

class EditChildScreen extends StatefulWidget {
  final StudentDetails child;

  const EditChildScreen({super.key, required this.child});

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController childNameController;
  late TextEditingController rollnoController;
  late TextEditingController sectionController;
  late TextEditingController dobController;
  late TextEditingController schoolNameController;
  late String _selectedGender;
  late String? selectedClass;
  int? age;

  final List<String> classOptions =
      List.generate(10, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    childNameController = TextEditingController(text: widget.child.childName);
    rollnoController = TextEditingController(text: widget.child.rollno);
    sectionController = TextEditingController(text: widget.child.section);
    dobController = TextEditingController(text: widget.child.dateOfBirth);
    schoolNameController = TextEditingController(text: widget.child.schoolName);
    _selectedGender = widget.child.gender;
    selectedClass = widget.child.className;
    age =
        calculateAge(DateFormat('dd/MM/yyyy').parse(widget.child.dateOfBirth));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Child Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildTextField(childNameController, "Child's name", Icons.person),
            const Gap(20),
            // _buildGenderSelection(),
            // const Gap(20),
            _buildDatePicker(),
            if (age != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Age: $age years',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            const Gap(20),
            _buildDropdown("Class", classOptions, selectedClass,
                (String? newValue) {
              setState(() {
                selectedClass = newValue;
              });
            }),
            const Gap(20),
            _buildTextField(rollnoController, "Roll No",
                Icons.format_list_numbered_rtl_rounded),
            const Gap(20),
            _buildSectionTextField(),
            const Gap(30),
            Consumer<ChildProvider>(builder: (context, childProvider, child) {
              return ElevatedButton(
                onPressed: childProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() &&
                            selectedClass != null &&
                            dobController.text.isNotEmpty) {
                          if (widget.child.childId.isNotEmpty) {
                            String? error = await childProvider.updateChild(
                              token: authProvider.token!,
                              childId: widget.child.childId,
                              childName: childNameController.text,
                              childAge: age.toString(),
                              className: selectedClass!,
                              rollno: rollnoController.text,
                              section: sectionController.text,
                              schoolName: schoolNameController.text,
                              gender: _selectedGender,
                              dateOfBirth: dobController.text,
                            );

                            if (error == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Child details updated successfully')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error updating child details: $error')),
                              );
                            }
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
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: AppColors.primaryColor,
                  elevation: 5,
                  shadowColor: AppColors.primaryColor.withOpacity(0.5),
                ),
                child: childProvider.isLoading
                    ? LoadingAnimationWidget.flickr(
                        leftDotColor: Colors.red,
                        rightDotColor: Colors.blue,
                        size: 30)
                    : Text(
                        'Update',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTextField() {
    return TextFormField(
      controller: sectionController,
      decoration: InputDecoration(
        prefixIcon:
            const Icon(Icons.group_work_rounded, color: AppColors.primaryColor),
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
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      maxLength: 1, // Limit to 1 character
      textCapitalization:
          TextCapitalization.characters, // Automatically capitalize input
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'[A-Za-z]')), // Allow only letters
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
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
        prefixIcon:
            const Icon(Icons.calendar_today, color: AppColors.primaryColor),
        hintText: "Date of Birth",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
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
