// ignore_for_file: unused_field

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/models/geofencing_model.dart';
import 'package:parentseye_parent/models/parent_student_model.dart.dart';
import 'package:parentseye_parent/models/positions_model.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/live_tracking_provider.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/geofences_provider.dart';

class TrackingScreen extends StatefulWidget {
  final int deviceId;
  final StudentDetails studentDetails;

  TrackingScreen({
    Key? key,
    required this.deviceId,
    required this.studentDetails,
  }) : super(key: key);

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _customIcon;
  String _currentIconPath = 'assets/Yellow.png';

  final List<LatLng> _polylineCoordinates = [];
  String _currentAddress = "Fetching address...";
  double _currentCourse = 0.0;
  String _nearestStop = "Calculating...";
  String _eta = "Calculating...";
  bool _isActive = true;
  bool isPanelOpen = false;

  LatLng? _lastPosition;
  double _lastCourse = 0.0;
  Color _currentBorderColor = Colors.yellow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final trackingProvider =
          Provider.of<TrackingProvider>(context, listen: false);
      final geofenceProvider =
          Provider.of<GeofenceProvider>(context, listen: false);

      await trackingProvider.fetchDevice(widget.studentDetails);
      await geofenceProvider.fetchGeofences(widget.deviceId.toString());

      if (mounted) {
        trackingProvider.startTracking(context);
      }
    });
    _startPositionListener();
  }

  Future<void> _launchCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  void _loadCustomIcon(String iconPath) async {
    if (!mounted) return;

    final ByteData data = await DefaultAssetBundle.of(context).load(iconPath);
    if (!_isActive) return;

    final ui.Codec codec = await ui
        .instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 40);
    if (!_isActive) return;

    final ui.FrameInfo fi = await codec.getNextFrame();
    if (!_isActive) return;

    final ByteData? byteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (!_isActive) return;

    final Uint8List resizedBytes = byteData!.buffer.asUint8List();

    if (mounted && _isActive) {
      setState(() {
        _customIcon = BitmapDescriptor.fromBytes(resizedBytes);
      });
    }
  }

  void _updateIconAndBorderColor(PositionsModel lastPosition) {
    Color newBorderColor;
    if (lastPosition.speed >= 10 &&
        lastPosition.attributes['ignition'] == true) {
      _currentIconPath = 'assets/Green.png';
      newBorderColor = Colors.green;
    } else if (lastPosition.speed <= 1 &&
        lastPosition.attributes['ignition'] == false) {
      _currentIconPath = 'assets/Red.png';
      newBorderColor = Colors.red;
    } else if (lastPosition.speed == 0 &&
        lastPosition.attributes['ignition'] == true) {
      _currentIconPath = 'assets/Yellow.png';
      newBorderColor = Colors.yellow;
    } else {
      _currentIconPath = 'assets/Yellow.png';
      newBorderColor = Colors.yellow;
    }

    _loadCustomIcon(_currentIconPath);
    setState(() {
      _currentBorderColor = newBorderColor;
    });
  }

  void _calculateNearestStopAndETA() {
    final trackingProvider =
        Provider.of<TrackingProvider>(context, listen: false);
    final geofenceProvider =
        Provider.of<GeofenceProvider>(context, listen: false);

    if (trackingProvider.positions.isEmpty ||
        geofenceProvider.geofences.isEmpty) {
      return;
    }

    PositionsModel currentPosition = trackingProvider.positions.last;
    LatLng currentLatLng =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    Geofence? nearestGeofence;
    double nearestDistance = double.infinity;

    for (var geofence in geofenceProvider.geofences) {
      double distance = _distanceBetween(currentLatLng, geofence.center);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestGeofence = geofence;
      }
    }

    setState(() {
      if (nearestGeofence != null) {
        _nearestStop = nearestGeofence.name;

        if (currentPosition.attributes['ignition'] == false &&
            currentPosition.speed == 0) {
          _eta = "M 00 : S 00";
        } else {
          double etaInHours = nearestDistance / 30;
          int totalSeconds = (etaInHours * 3600).round();
          int minutes = totalSeconds ~/ 60;
          int seconds = totalSeconds % 60;
          _eta =
              "M ${minutes.toString().padLeft(2, '0')} : S ${seconds.toString().padLeft(2, '0')}";
        }
      } else {
        _nearestStop = "No stop found";
        _eta = "N/A";
      }
    });
  }

  void _startPositionListener() {
    Provider.of<TrackingProvider>(context, listen: false).addListener(() {
      if (mounted) {
        final provider = Provider.of<TrackingProvider>(context, listen: false);

        // Only update when we have an animated position
        if (provider.currentAnimatedPosition != null) {
          _updatePolyline(provider.positions);

          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: provider.currentAnimatedPosition!,
                  zoom: 17,
                  bearing: provider.currentAnimatedBearing,
                ),
              ),
            );
          }

          _getAddressFromLatLng(provider.currentAnimatedPosition!);
          setState(() {
            _currentCourse = provider.currentAnimatedBearing;
          });
          _calculateNearestStopAndETA();

          if (provider.positions.isNotEmpty) {
            _updateIconAndBorderColor(provider.positions.last);
          }
        }
      }
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  void _moveCamera(LatLng position, double course) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 17,
            bearing: course,
          ),
        ),
      );
    }
  }

  double _calculatePanelContentHeight(BuildContext context) {
    double addressRowHeight = 80.0;
    double etaRowHeight = 60.0;
    double callButtonsRowHeight = 60.0;
    double contentHeight =
        addressRowHeight + etaRowHeight + callButtonsRowHeight;
    contentHeight += 20.0;
    contentHeight += 16.0;

    return contentHeight;
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geofenceProvider = Provider.of<GeofenceProvider>(context);
    final geofences = geofenceProvider.geofences;
    final authProvider = Provider.of<AuthProvider>(context);
    final bool fullAccess = authProvider.hasFullAccess;

    double panelContentHeight = _calculatePanelContentHeight(context);
    double maxPanelHeight = panelContentHeight + 20.0;
    double minPanelHeight = 115.0;

    // Create circle overlays for geofences
    Set<Circle> circles = geofences.map((geofence) {
      return Circle(
        circleId: CircleId(geofence.id),
        center: geofence.center,
        radius: geofence.radius,
        fillColor: AppColors.primaryColor.withOpacity(0.5),
        strokeColor: AppColors.primaryColor,
        strokeWidth: 2,
      );
    }).toSet();

    return Scaffold(
      appBar: fullAccess == false
          ? AppBar(
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              title: const Text("Live Tracking"),
              centerTitle: true,
            )
          : null,
      body: Stack(
        children: [
          Consumer<TrackingProvider>(
            builder: (context, provider, child) {
              if (provider.positions.isEmpty ||
                  provider.currentAnimatedPosition == null) {
                return Center(
                  child: LoadingAnimationWidget.flickr(
                    leftDotColor: Colors.red,
                    rightDotColor: Colors.blue,
                    size: 30,
                  ),
                );
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: provider.currentAnimatedPosition!,
                  zoom: 17.0,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('carPath'),
                    color: Colors.blue,
                    width: 5,
                    points: _polylineCoordinates,
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('car'),
                    position: provider.currentAnimatedPosition!,
                    icon: _customIcon ?? BitmapDescriptor.defaultMarker,
                    rotation: provider.currentAnimatedBearing,
                    anchor: const Offset(0.5, 0.5),
                    flat: true,
                  ),
                },
                circles: circles,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                compassEnabled: false,
                mapType: MapType.normal,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
              );
            },
          ),
          SlidingUpPanel(
            maxHeight:
                fullAccess == true ? maxPanelHeight : panelContentHeight - 70,
            minHeight: minPanelHeight,
            color: Colors.transparent,
            defaultPanelState: PanelState.OPEN,
            onPanelSlide: (double pos) => setState(() {
              isPanelOpen = pos > 0.5;
            }),
            panel: Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: panelContentHeight,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 10.0,
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: _currentBorderColor,
                              width: 5.0,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Consumer<TrackingProvider>(
                                builder: (context, provider, child) {
                                  return buildRowItem1(_currentAddress);
                                },
                              ),
                              if (fullAccess == true) buildDivider1(),
                              if (fullAccess == true) buildRowItem2(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: buildDivider(),
                              ),
                              // buildRowItem3(
                              //   'Call Driver',
                              //   "Call School",
                              //   Icons.call,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  child: Icon(
                    isPanelOpen
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 35,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18.0)),
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return const Divider(
      color: Colors.grey,
      height: 8.0,
      thickness: 0.5,
    );
  }

  Widget buildDivider1() {
    return const Padding(
      padding: EdgeInsets.only(left: 80.0),
      child: Divider(
        color: Colors.grey,
        height: 8.0,
        thickness: 0.5,
      ),
    );
  }

  Widget buildRowItem3(String text, String text3, IconData iconData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () => _launchCall(widget.studentDetails.driverMobile),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow.shade600,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              iconData,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(width: 8.0),
        GestureDetector(
          onTap: () => _launchCall(widget.studentDetails.schoolMobile),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow.shade600,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              iconData,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          text3,
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Widget buildRowItem2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8.0),
        Text(
          "ETA: $_eta",
          style:
              GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          "Nearest Stop: $_nearestStop",
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.yellow.shade900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildRowItem1(String title) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Image.asset("assets/school_bus.png"),
            ),
            const SizedBox(width: 18.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15.0),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // const SizedBox(height: 4.0),
                  // Text(
                  //   provider.getLastUpdateTimeIndian(),
                  //   style: TextStyle(
                  //     fontSize: 12.0,
                  //     color: Colors.grey[600],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  LatLng _calculateGeofenceCenter(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;

    for (var point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return LatLng(latitude / points.length, longitude / points.length);
  }

  double _calculateGeofenceRadius(List<LatLng> points) {
    LatLng center = _calculateGeofenceCenter(points);
    double maxDistance = 0;

    for (var point in points) {
      double distance = _distanceBetween(center, point);
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }

    return maxDistance * 1000;
  }

  double _distanceBetween(LatLng start, LatLng end) {
    var earthRadiusKm = 6371;

    var dLat = _degreesToRadians(end.latitude - start.latitude);
    var dLng = _degreesToRadians(end.longitude - start.longitude);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _updatePolyline(List<PositionsModel> positions) {
    setState(() {
      if (_polylineCoordinates.isEmpty ||
          _polylineCoordinates.last !=
              LatLng(positions.last.latitude, positions.last.longitude)) {
        _polylineCoordinates
            .add(LatLng(positions.last.latitude, positions.last.longitude));
      }
    });
  }
}
