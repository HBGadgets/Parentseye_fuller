import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:parentseye_parent/constants/api_constants.dart';

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initNotification(String? parentId) async {
    print("Initializing notifications");
    await _requestPermission();
    await _initializeLocalNotifications();

    if (parentId != null) {
      _configureFirebaseListeners();
      await updateFCMToken(parentId);
    }
    print("Notification initialization complete");
  }

  Future<void> _requestPermission() async {
    print("Requesting notification permissions");
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    print("Initializing local notifications");

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Local notification tapped: ${details.payload}");
      },
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print("Local notifications initialized");
  }

  void _configureFirebaseListeners() {
    print("Configuring Firebase listeners");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message while in foreground!");
      print("Message data: ${message.data}");
      if (message.notification != null) {
        print("Notification title: ${message.notification!.title}");
        print("Notification body: ${message.notification!.body}");
        _showNotification(message);
        _speakNotification(
            message.notification!.title, message.notification!.body);
      } else {
        print("Received a data message without notification payload");
        // Handle data message if needed
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from a background state: ${message.data}");
    });

    print("Firebase listeners configured");
  }

  Future<void> updateFCMToken(String parentId) async {
    String? token = await getFCMToken();
    if (token != null) {
      await _sendTokenToServer(token, parentId);
    }
  }

  Future<void> _sendTokenToServer(String token, String parentId) async {
    const String url = ApiConstants.updateFcmToken;

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'parentId': parentId,
          'fcmToken': token,
        }),
      );

      if (response.statusCode == 200) {
        print('FCM token updated successfully');
      } else {
        print(
            'Failed to update FCM token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    print("Showing local notification");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        platformChannelSpecifics,
      );
      print("Local notification shown successfully");
    } catch (e) {
      print("Error showing local notification: $e");
    }
  }

  Future<void> _speakNotification(String? title, String? body) async {
    print("Speaking notification");
    String textToSpeak = '';
    if (title != null) {
      textToSpeak += 'Title: $title. ';
    }
    if (body != null) {
      textToSpeak += 'Message: $body';
    }

    if (textToSpeak.isNotEmpty) {
      await _flutterTts.speak(textToSpeak);
    }
    print("Notification spoken");
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token retrieved: $token");
      return token;
    } catch (e) {
      print("Error retrieving FCM token: $e");
      return null;
    }
  }
}