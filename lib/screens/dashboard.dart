import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/child_provider.dart';
import 'package:parentseye_parent/screens/about_us.dart';
import 'package:parentseye_parent/screens/account_details.dart';
import 'package:parentseye_parent/screens/help_support.dart';
import 'package:parentseye_parent/screens/place_a_request.dart';
import 'package:parentseye_parent/screens/requests_history_screen.dart';
import 'package:parentseye_parent/screens/settings_screen.dart';
import 'package:parentseye_parent/screens/track_child/bus_tracking_pageview.dart.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final childProvider = Provider.of<ChildProvider>(context, listen: false);
      childProvider.fetchParentStudentData(authProvider.token!);
      _onRefresh();
    });
  }

  void _onRefresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    await childProvider.fetchParentStudentData(authProvider.token!);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = Provider.of<ChildProvider>(context);
    ParentStudentModel? familyData = childProvider.parentStudentModel;
    final authProvider = Provider.of<AuthProvider>(context);
    final bool fullAccess = authProvider.hasFullAccess;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 50, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    familyData?.parentDetails.parentName ?? 'Parent Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            if (fullAccess == true)
              _buildTile(
                icon: Icons.account_circle,
                title: 'Account Details',
                subtitle: 'Manage your personal information',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountDetails()));
                },
              ),
            if (fullAccess == true)
              _buildTile(
                icon: Icons.query_builder_rounded,
                title: 'Place a Request',
                subtitle: 'Manage and Place your requests',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlaceARequest()));
                },
              ),
            if (fullAccess == true)
              _buildTile(
                icon: Icons.remove_from_queue_sharp,
                title: 'My Requests',
                subtitle: 'View your requests',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestHistory()));
                },
              ),
            if (fullAccess == true)
              _buildTile(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'Customize app preferences',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            _buildTile(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get assistance and FAQs',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpAndSupportScreen()));
              },
            ),
            _buildTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'Version and app details',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutUsScreen()));
              },
            ),
            if (fullAccess == false)
              _buildTile(
                icon: Icons.info,
                title: 'Logout',
                subtitle: 'Go back to Login page',
                onTap: () {
                  authProvider.logout(context);
                },
              ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: SizedBox(
            height: 120,
            width: 120,
            child: Image.asset('assets/parentseye_logo.png')),
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          waterDropColor: AppColors.primaryColor,
          complete: Icon(Icons.check, color: AppColors.primaryColor),
          refresh: LoadingAnimationWidget.flickr(
              leftDotColor: Colors.red, rightDotColor: Colors.blue, size: 30),
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: familyData == null
            ? _buildSkeletonLoading()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (var student in familyData.children)
                    StudentCard(student: student),
                ],
              ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        tileColor: AppColors.tileColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

/// Student card
class StudentCard extends StatelessWidget {
  final StudentDetails student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusTrackingPageView(
              student: student,
            ),
          ),
        );
      },
      child: Card(
        color: AppColors.primaryColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.textLightColor)),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.black, width: 2)),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 50,
                            backgroundImage: AssetImage(
                              'assets/student-card-icon.png',
                            ),
                          ),
                        ),
                      ),
                      Text(
                        student.childName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              buildInfoRow('Class', student.className),
              buildInfoRow('Section', student.section),
              buildInfoRow('School', student.schoolName),
              buildInfoRow('Branch', student.branchName),
              buildInfoRow('Bus Stop', student.pickupPoint),
              buildInfoRow('Bus Name', student.deviceName),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, var value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textLightColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
