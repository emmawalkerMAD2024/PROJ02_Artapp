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
    apiKey: 'AIzaSyAk6eLvH85ZzK-HgSgFyeZ7SaJa646SrTs',
    appId: '1:593693771697:web:5540eb9f2c0f4c563c9f90',
    messagingSenderId: '593693771697',
    projectId: 'artlink-studio',
    authDomain: 'artlink-studio.firebaseapp.com',
    storageBucket: 'artlink-studio.firebasestorage.app',
    measurementId: 'G-6VX6DHMRT6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANNLpNhQeAlkxxh9Dql9DZk8Ja1s4yCYs',
    appId: '1:593693771697:android:b2e12b0cc955b6243c9f90',
    messagingSenderId: '593693771697',
    projectId: 'artlink-studio',
    storageBucket: 'artlink-studio.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXLZuVQ3N2itFFDVPOTqL3Nb0j-woE0YU',
    appId: '1:593693771697:ios:ecf60dc6208319593c9f90',
    messagingSenderId: '593693771697',
    projectId: 'artlink-studio',
    storageBucket: 'artlink-studio.firebasestorage.app',
    iosBundleId: 'com.example.p2Artapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXLZuVQ3N2itFFDVPOTqL3Nb0j-woE0YU',
    appId: '1:593693771697:ios:ecf60dc6208319593c9f90',
    messagingSenderId: '593693771697',
    projectId: 'artlink-studio',
    storageBucket: 'artlink-studio.firebasestorage.app',
    iosBundleId: 'com.example.p2Artapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAk6eLvH85ZzK-HgSgFyeZ7SaJa646SrTs',
    appId: '1:593693771697:web:7e63f3b2622438c53c9f90',
    messagingSenderId: '593693771697',
    projectId: 'artlink-studio',
    authDomain: 'artlink-studio.firebaseapp.com',
    storageBucket: 'artlink-studio.firebasestorage.app',
    measurementId: 'G-LL21YPP293',
  );
}
