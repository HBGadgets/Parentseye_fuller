import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/api_constants.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class StudentStatusDetails extends StatefulWidget {
  final StudentDetails student;

  const StudentStatusDetails({super.key, required this.student});

  @override
  _StudentStatusDetailsState createState() => _StudentStatusDetailsState();
}

class _StudentStatusDetailsState extends State<StudentStatusDetails> {
  late Future<Map<String, dynamic>?> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _fetchStudentStatus(widget.student.childId);
  }

  Future<Map<String, dynamic>?> _fetchStudentStatus(String childId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.childPickDropStatus}$childId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching student status: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: LoadingAnimationWidget.flickr(
                  leftDotColor: Colors.red,
                  rightDotColor: Colors.blue,
                  size: 30));
        }
        return _buildStatusCard(widget.student, snapshot.data);
      },
    );
  }

  Widget _buildStatusCard(
      StudentDetails student, Map<String, dynamic>? statusData) {
    bool hasStatus = statusData != null && statusData.isNotEmpty;

    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.childName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                'Class: ${student.className} ${student.section}, Roll No: ${student.rollno}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                student.schoolName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              if (hasStatus) ...[
                _buildStatusRow(
                  'Picked up from Bus stop',
                  statusData['pickupStatus'],
                  statusData['pickupTime'],
                ),
                const SizedBox(height: 8),
                _buildStatusRow(
                  'Dropped to Bus stop',
                  statusData['dropStatus'],
                  statusData['dropTime'],
                ),
              ] else ...[
                Text(
                  'No status available',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool? status, String? time) {
    Color statusColor = (status == true) ? Colors.green : Colors.orange;
    String statusText = (status == true) ? time ?? 'N/A' : 'Not Yet';

    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: statusColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            '$label at $statusText',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
