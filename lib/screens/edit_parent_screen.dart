import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/parent_provider.dart';
import 'package:parentseye_parent/screens/delete_account_screen.dart';
import 'package:parentseye_parent/widgets/error_dialog.dart';
import 'package:parentseye_parent/widgets/success_dialog.dart';
import 'package:provider/provider.dart';

class UpdateParentScreen extends StatefulWidget {
  const UpdateParentScreen({super.key});

  @override
  _UpdateParentScreenState createState() => _UpdateParentScreenState();
}

class _UpdateParentScreenState extends State<UpdateParentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _parentNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _parentId;

  @override
  void initState() {
    super.initState();
    final parentProvider = Provider.of<ParentProvider>(context, listen: false);
    final parent = parentProvider.parent;
    if (parent != null) {
      _parentId = parent.id;
      _parentNameController = TextEditingController(text: parent.parentName);
      _emailController = TextEditingController(text: parent.email);
      _phoneController = TextEditingController(text: parent.phone.toString());
      if (!_phoneController.text.startsWith('+91')) {
        _phoneController.text = '+91${_phoneController.text}';
      }
    } else {
      _parentId = '';
      _parentNameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController(text: '+91');
    }
  }

  @override
  void dispose() {
    _parentNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final parentProvider =
          Provider.of<ParentProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      String? error = await parentProvider.updateParent(
        token: authProvider.token!,
        parentId: _parentId,
        parentName: _parentNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      if (error == null) {
        SuccessDialog.showSuccessDialog(
          context,
          'Parent details updated successfully!',
        );
      } else {
        ErrorDialog.showErrorDialog(
          context,
          'Error updating parent details: $error',
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (Platform.isIOS)
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DeleteAccountScreen()),
                  );
                },
                child: Text(
                  "Delete Account",
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _parentNameController,
                  hintText: 'Parent Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  hintText: 'Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 0.5,
                    child: Consumer<ParentProvider>(
                      builder: (context, parentProvider, child) {
                        return ElevatedButton(
                          onPressed:
                              parentProvider.isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: AppColors.primaryColor,
                            elevation: 5,
                            shadowColor:
                                AppColors.primaryColor.withOpacity(0.5),
                          ),
                          child: parentProvider.isLoading
                              ? LoadingAnimationWidget.flickr(
                                  leftDotColor: Colors.red,
                                  rightDotColor: Colors.blue,
                                  size: 30)
                              : Text(
                                  'Update',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
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
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      inputFormatters: inputFormatters,
      // onChanged: (value) {
      //   if (hintText == 'Phone' && !value.startsWith('+91')) {
      //     controller.value = TextEditingValue(
      //       text: '+91' + value.replaceAll('+91', ''),
      //       selection: TextSelection.collapsed(offset: value.length + 3),
      //     );
      //   }
      // },`
    );
  }
}

// class PhoneNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     // Always keep the +91 prefix
//     if (newValue.text.length < 3) {
//       return const TextEditingValue(
//         text: '+91',
//         selection: TextSelection.collapsed(offset: 3),
//       );
//     }

//     // If the user is deleting, allow it but keep the +91 prefix
//     if (oldValue.text.length > newValue.text.length) {
//       return newValue.copyWith(text: '+91' + newValue.text.substring(3));
//     }

//     // For other cases, ensure the +91 prefix is maintained
//     if (!newValue.text.startsWith('+91')) {
//       return TextEditingValue(
//         text: '+91' + newValue.text.substring(min(newValue.text.length, 3)),
//         selection: TextSelection.collapsed(offset: newValue.text.length),
//       );
//     }

//     return newValue;
//   }
// }
