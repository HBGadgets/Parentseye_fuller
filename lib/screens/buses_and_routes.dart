import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parentseye_parent/constants/app_colors.dart';

class BusesAndRoutes extends StatelessWidget {
  const BusesAndRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bus Routes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            BusRouteCard(
              busNumber: "Bus 101",
              fromAddress: "Start Address 1",
              toAddress: "End Address 1",
              timeline: "8:00 AM - 9:30 AM",
            ),
            BusRouteCard(
              busNumber: "Bus 202",
              fromAddress: "Start Address 2",
              toAddress: "End Address 2",
              timeline: "10:00 AM - 11:30 AM",
            ),
            BusRouteCard(
              busNumber: "Bus 303",
              fromAddress: "Start Address 3",
              toAddress: "End Address 3",
              timeline: "1:00 PM - 2:30 PM",
            ),
          ],
        ),
      ),
    );
  }
}

class BusRouteCard extends StatelessWidget {
  final String busNumber;
  final String fromAddress;
  final String toAddress;
  final String timeline;

  const BusRouteCard({
    super.key,
    required this.busNumber,
    required this.fromAddress,
    required this.toAddress,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  busNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  timeline,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RoutePointWidget(
              icon: Icons.trip_origin,
              address: fromAddress,
              color: Colors.green,
            ),
            const RouteLineWidget(),
            RoutePointWidget(
              icon: Icons.place,
              address: toAddress,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, color: AppColors.textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutePointWidget extends StatelessWidget {
  final IconData icon;
  final String address;
  final Color color;

  const RoutePointWidget({
    super.key,
    required this.icon,
    required this.address,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class RouteLineWidget extends StatelessWidget {
  const RouteLineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      height: 30,
      width: 2,
      color: Colors.grey.shade400,
    );
  }
}
