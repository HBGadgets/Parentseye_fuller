import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:provider/provider.dart';

import '../../provider/geofences_provider.dart';
import '../../provider/live_tracking_provider.dart';

class RouteDetails extends StatefulWidget {
  final int deviceId;
  const RouteDetails({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<RouteDetails> createState() => _RouteDetailsState();
}

class _RouteDetailsState extends State<RouteDetails>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GeofenceProvider>(context, listen: false)
          .fetchGeofences(widget.deviceId.toString());
      Provider.of<TrackingProvider>(context, listen: false)
          .startTracking(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GeofenceProvider, TrackingProvider>(
      builder: (context, geofenceProvider, trackingProvider, child) {
        final geofences = geofenceProvider.geofences;
        final currentPosition = trackingProvider.positions.isNotEmpty
            ? trackingProvider.positions.last
            : null;

        if (geofences.isEmpty || currentPosition == null) {
          return Center(
              child: LoadingAnimationWidget.flickr(
                  leftDotColor: Colors.red,
                  rightDotColor: Colors.blue,
                  size: 30));
        }

        return ListView.builder(
          itemCount: geofences.length,
          itemBuilder: (context, index) {
            final geofence = geofences[index];
            final isEntered = geofence.isCrossed;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 130,
                    color: Colors.black,
                    child: CustomPaint(
                      painter: DottedLinePainter(isCrossed: isEntered),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isEntered ? Colors.green : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 121,
                      child: Card(
                        elevation: 0.1,
                        color: isEntered ? Colors.green : Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: Image.asset("assets/yellow-sign.png"),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          geofence.busStopTime,
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColor),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Bus Stop: ${geofence.name}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isEntered
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Arrival: ${geofence.arrivalTime ?? 'Not yet'}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isEntered
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Gap(4),
                                    Text(
                                      "Departure: ${geofence.departureTime ?? 'Not yet'}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isEntered
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final bool isCrossed;

  DottedLinePainter({required this.isCrossed});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isCrossed ? Colors.green : Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    const double dashWidth = 20.0;
    const double dashSpace = 10.0;

    double currentX = 0.0;
    while (currentX < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, currentX),
        Offset(size.width / 2, currentX + dashWidth),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
