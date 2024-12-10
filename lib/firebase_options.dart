// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4j4LFreffRyj9utms6WsFid-nn1FEiUA',
    appId: '1:670925031335:web:ad8b5f2489435461d89882',
    messagingSenderId: '670925031335',
    projectId: 'parentseye-parent-bbe6a',
    authDomain: 'parentseye-parent-bbe6a.firebaseapp.com',
    storageBucket: 'parentseye-parent-bbe6a.appspot.com',
    measurementId: 'G-EX4BC2E6VS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBuhtE-RNeykjkdmpZETm2XuzVgAGH6JkA',
    appId: '1:670925031335:android:52575bb3cf9c1271d89882',
    messagingSenderId: '670925031335',
    projectId: 'parentseye-parent-bbe6a',
    storageBucket: 'parentseye-parent-bbe6a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYfUtluaZk-7VQjTxPCljjRk7-lLVNtHQ',
    appId: '1:670925031335:ios:919efdc8009afefdd89882',
    messagingSenderId: '670925031335',
    projectId: 'parentseye-parent-bbe6a',
    storageBucket: 'parentseye-parent-bbe6a.appspot.com',
    iosBundleId: 'com.parentseye.parent',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYfUtluaZk-7VQjTxPCljjRk7-lLVNtHQ',
    appId: '1:670925031335:ios:754158f41694b967d89882',
    messagingSenderId: '670925031335',
    projectId: 'parentseye-parent-bbe6a',
    storageBucket: 'parentseye-parent-bbe6a.appspot.com',
    iosBundleId: 'com.example.credenceSchools',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB4j4LFreffRyj9utms6WsFid-nn1FEiUA',
    appId: '1:670925031335:web:4a88deda2d4547c2d89882',
    messagingSenderId: '670925031335',
    projectId: 'parentseye-parent-bbe6a',
    authDomain: 'parentseye-parent-bbe6a.firebaseapp.com',
    storageBucket: 'parentseye-parent-bbe6a.appspot.com',
    measurementId: 'G-MTVXL2J46C',
  );
}