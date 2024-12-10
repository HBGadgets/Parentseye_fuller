import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/request_history_model.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/request_provider.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class RequestHistory extends StatefulWidget {
  const RequestHistory({super.key});

  @override
  _RequestHistoryState createState() => _RequestHistoryState();
}

class _RequestHistoryState extends State<RequestHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final requestProvider =
          Provider.of<RequestProvider>(context, listen: false);

      if (authProvider.token != null) {
        requestProvider.fetchRequestHistory(authProvider.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please log in again.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.backgroundColor,
        child: Consumer<RequestProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: 5, // show a few skeleton cards for loading state
                itemBuilder: (context, index) {
                  return const SkeletonRequestCard();
                },
              );
            } else if (provider.requests.isEmpty) {
              return const Center(child: Text('No requests found'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.requests.length,
                itemBuilder: (context, index) {
                  final request = provider.requests[index];
                  return RequestDetailsCard(request: request);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class RequestDetailsCard extends StatelessWidget {
  final RequestHistoryModel request;

  const RequestDetailsCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: AppColors.surfaceColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.childName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),
            RequestInfoRow(
              icon: Icons.type_specimen,
              text: "Request Type: ${request.requestType}",
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            if (request.requestType == 'leave') ...[
              RequestInfoRow(
                icon: Icons.calendar_today,
                text: "Leave from: ${_formatLeaveDate(request.startDate)}",
                color: Colors.purple,
              ),
              const SizedBox(height: 8),
              RequestInfoRow(
                icon: Icons.calendar_today,
                text: "Leave till: ${_formatLeaveDate(request.endDate)}",
                color: Colors.purple,
              ),
            ],
            if (request.requestType == 'changeRoute') ...[
              RequestInfoRow(
                icon: Icons.route,
                text: "New Route: ${request.newRoute}",
                color: Colors.blue,
              ),
            ],
            const SizedBox(height: 8),
            RequestInfoRow(
              icon: Icons.info_outline,
              text: "Reason: ${request.reason}",
              color: Colors.green,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatDate(request.requestDate),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLightColor.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    final date = DateTime.parse(dateString)
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30));
    return DateFormat('hh:mm a dd-MM-yyyy').format(date);
  }

  String _formatLeaveDate(String? dateString) {
    if (dateString == null) return 'N/A';
    final date = DateTime.parse(dateString)
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30));
    return DateFormat('dd-MM-yyyy').format(date);
  }
}

class SkeletonRequestCard extends StatelessWidget {
  const SkeletonRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 18,
                  width: 120,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 16,
                  width: 200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 16,
                  width: 180,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 16,
                  width: 150,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const RequestInfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textLightColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
