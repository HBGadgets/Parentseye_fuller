import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parentseye_parent/constants/app_colors.dart';
import 'package:parentseye_parent/firebase_options.dart';
import 'package:parentseye_parent/provider/auth_provider.dart';
import 'package:parentseye_parent/provider/child_provider.dart';
import 'package:parentseye_parent/provider/delete_account_provider.dart';
import 'package:parentseye_parent/provider/devices_provider.dart';
import 'package:parentseye_parent/provider/geofences_provider.dart';
import 'package:parentseye_parent/provider/live_tracking_provider.dart';
import 'package:parentseye_parent/provider/parent_provider.dart';
import 'package:parentseye_parent/provider/request_provider.dart';
import 'package:parentseye_parent/provider/school_provider.dart';
import 'package:parentseye_parent/screens/dashboard.dart';
import 'package:parentseye_parent/screens/parent_login_screen.dart';
import 'package:parentseye_parent/screens/settings_screen.dart';
import 'package:parentseye_parent/screens/splash_screen.dart';
import 'package:parentseye_parent/services/notification_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const String MINIMUM_VERSION = "1.0.24";

  static const String PLAYSTORE_MARKET_URL =
      'market://details?id=com.parentseye.parent_app';
  static const String PLAYSTORE_WEB_URL =
      'https://play.google.com/store/apps/details?id=com.parentseye.parent_app';
  static const String APPSTORE_URL =
      'itms-apps://itunes.apple.com/app/id6677037755';

  static Future<bool> checkForUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      bool updateNeeded = _isUpdateRequired(currentVersion, MINIMUM_VERSION);

      if (updateNeeded) {
        await showUpdateDialog(context);
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  static bool _isUpdateRequired(String currentVersion, String minimumVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> minimum = minimumVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (current[i] < minimum[i]) return true;
      if (current[i] > minimum[i]) return false;
    }
    return false;
  }

  static Future<void> _launchStore(String url, String fallbackUrl) async {
    try {
      final Uri uri = Uri.parse(url);
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        final Uri fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(
          fallbackUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Error launching store: $e');
      try {
        final Uri fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(
          fallbackUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('Error launching fallback URL: $e');
      }
    }
  }

  static Future<void> showUpdateDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'A new version of the app is available. Please update to continue using the app.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (Theme.of(context).platform == TargetPlatform.iOS) {
                  await _launchStore(APPSTORE_URL, APPSTORE_URL);
                } else {
                  await _launchStore(PLAYSTORE_MARKET_URL, PLAYSTORE_WEB_URL);
                }
              },
              child: Text(
                'Update Now',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");
  runApp(const MyApp());
}

class UpdateWrapper extends StatefulWidget {
  final Widget child;

  const UpdateWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _UpdateWrapperState createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends State<UpdateWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ParentProvider()),
        ChangeNotifierProvider(create: (context) => ChildProvider()),
        ChangeNotifierProvider(create: (context) => RequestProvider()),
        ChangeNotifierProvider(create: (context) => TrackingProvider()),
        ChangeNotifierProvider(create: (context) => GeofenceProvider()),
        ChangeNotifierProvider(create: (context) => DeviceProvider()),
        ChangeNotifierProvider(create: (context) => SchoolProvider()),
        ChangeNotifierProvider(create: (_) => DeleteAccountProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            theme: settingsProvider.darkModeEnabled
                ? ThemeData.dark()
                : ThemeData.light(),
            home: UpdateWrapper(
              child: Builder(
                builder: (BuildContext context) {
                  NotificationServices notificationServices =
                      NotificationServices();

                  return Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return FutureBuilder(
                        future: authProvider.initialized,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Scaffold(
                              body: SplashScreen(),
                            );
                          } else if (authProvider.isAuthenticated) {
                            if (authProvider.parentStudentModel != null) {
                              String parentId = authProvider
                                  .parentStudentModel!.parentDetails.parentId;
                              notificationServices.initNotification(parentId);
                              notificationServices.updateFCMToken(parentId);
                            } else {
                              notificationServices.initNotification(null);
                            }
                            return const Dashboard();
                          } else {
                            return const ParentalLogin();
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:parentseye_parent/socket_testwidget.dart';

// void main() {
//   runApp(TestSocket());
// }

// class TestSocket extends StatelessWidget {
//   const TestSocket({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SocketJsonViewer(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
