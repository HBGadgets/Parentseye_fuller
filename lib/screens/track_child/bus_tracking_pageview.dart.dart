import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/screens/track_child/route.dart';
import 'package:parentseye_parent/screens/track_child/status.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import 'live_map.dart';

class BusTrackingPageView extends StatefulWidget {
  final StudentDetails student;
  const BusTrackingPageView({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  _BusTrackingPageViewState createState() => _BusTrackingPageViewState();
}

class _BusTrackingPageViewState extends State<BusTrackingPageView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool fullAccess = authProvider.hasFullAccess;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(
        children: [
          if (fullAccess == true) _buildTopNavBar(),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: Colors.white,
                child: fullAccess == true
                    ? IndexedStack(
                        index: _currentIndex,
                        children: [
                          TrackingScreen(
                            studentDetails: widget.student,
                            deviceId: int.parse(widget.student.deviceId),
                          ),
                          RouteDetails(
                            deviceId: int.parse(widget.student.deviceId),
                          ),
                          StudentStatusDetails(
                            student: widget.student,
                          ),
                        ],
                      )
                    : TrackingScreen(
                        studentDetails: widget.student,
                        deviceId: int.parse(widget.student.deviceId),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          activeColor: AppColors.textColor,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.white.withOpacity(0.1),
          color: Colors.white,
          tabs: const [
            GButton(
              icon: Icons.map,
              text: 'Live',
            ),
            GButton(
              icon: Icons.route,
              text: 'Route',
            ),
            GButton(
              icon: Icons.person,
              text: 'Status',
            ),
          ],
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
