import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/parent_only_model.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/child_provider.dart';
import 'package:parentseye_parent/provider/parent_provider.dart';
import 'package:parentseye_parent/screens/add_child_screen.dart';
import 'package:parentseye_parent/screens/edit_child_screen.dart';
import 'package:parentseye_parent/screens/edit_parent_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final parentProvider =
          Provider.of<ParentProvider>(context, listen: false);
      final childProvider = Provider.of<ChildProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        parentProvider.fetchAndSetParentData(authProvider.token!);
        childProvider.fetchParentStudentData(authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Account",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(),
                _buildChildrenSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddChildScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Add Child +',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        Parent? parentData = parentProvider.parent;

        return Column(
          children: [
            const SizedBox(height: 20),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      parentData != null
                          ? Text(
                              parentData.parentName,
                              style: GoogleFonts.aBeeZee(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : _buildShimmerText(width: 150, height: 22),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UpdateParentScreen()),
                          );
                        },
                        child: Text(
                          "Edit",
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone_android),
                          const SizedBox(width: 4),
                          parentData != null
                              ? Text(
                                  "${parentData.phone}",
                                  style: GoogleFonts.poppins(fontSize: 14.0),
                                )
                              : _buildShimmerText(width: 100, height: 14),
                        ],
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined),
                          const SizedBox(width: 4),
                          parentData != null
                              ? Text(
                                  parentData.email,
                                  style: GoogleFonts.poppins(fontSize: 14.0),
                                )
                              : _buildShimmerText(width: 150, height: 14),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChildrenSection() {
    return Consumer<ChildProvider>(
      builder: (context, childProvider, _) {
        ParentStudentModel? familyData = childProvider.parentStudentModel;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "My children",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
              ),
            ),
            familyData != null
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: familyData.children.length,
                    itemBuilder: (context, index) {
                      StudentDetails student = familyData.children[index];
                      return _buildChildCard(student);
                    },
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) => _buildShimmerChildCard(),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildChildCard(StudentDetails student) {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: ListTile(
        leading: _getGenderImage(student.gender),
        title: Text(
          student.childName,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Class: ${student.className}"),
            Text("School: ${student.schoolName}"),
          ],
        ),
        trailing: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditChildScreen(child: student),
              ),
            );
          },
          child: Text(
            "Edit",
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerChildCard() {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          radius: 20,
        ),
        title: _buildShimmerText(width: 120, height: 16),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerText(width: 80, height: 12),
            const SizedBox(height: 4),
            _buildShimmerText(width: 100, height: 12),
          ],
        ),
        trailing: _buildShimmerText(width: 40, height: 20),
      ),
    );
  }

  Widget _buildShimmerText({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _getGenderImage(String gender) {
    String assetPath;

    switch (gender.toLowerCase()) {
      case 'male':
        assetPath = 'assets/boy_icon.png';
        break;
      case 'female':
        assetPath = 'assets/girl_icon.png';
        break;
      default:
        assetPath = 'assets/boy_icon.png';
    }

    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Image.asset(
        assetPath,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}
