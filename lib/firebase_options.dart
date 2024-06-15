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
    apiKey: 'AIzaSyDzJskK6m9KF9yVNIzxvI7TTSwPGx0Le0s',
    appId: '1:491693754365:web:9a5fda5d42404a25c5fb94',
    messagingSenderId: '491693754365',
    projectId: 'event-management-f73f5',
    authDomain: 'event-management-f73f5.firebaseapp.com',
    storageBucket: 'event-management-f73f5.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwSDwllBJuUYL2vbTqqUrDM3OHWXyDNL8',
    appId: '1:491693754365:android:d176ee56ce7e71d9c5fb94',
    messagingSenderId: '491693754365',
    projectId: 'event-management-f73f5',
    storageBucket: 'event-management-f73f5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHn0ux5M69H6TYVY8AynDfLcJxDVNUcV4',
    appId: '1:491693754365:ios:f8e1eaad79fca7e2c5fb94',
    messagingSenderId: '491693754365',
    projectId: 'event-management-f73f5',
    storageBucket: 'event-management-f73f5.appspot.com',
    androidClientId: '491693754365-gnk0luoi4eh1roagh5g1am83ffv122gc.apps.googleusercontent.com',
    iosClientId: '491693754365-biugaibgovknh1flg9qufg8266ih4uj4.apps.googleusercontent.com',
    iosBundleId: 'com.example.admineventpro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDHn0ux5M69H6TYVY8AynDfLcJxDVNUcV4',
    appId: '1:491693754365:ios:f8e1eaad79fca7e2c5fb94',
    messagingSenderId: '491693754365',
    projectId: 'event-management-f73f5',
    storageBucket: 'event-management-f73f5.appspot.com',
    androidClientId: '491693754365-gnk0luoi4eh1roagh5g1am83ffv122gc.apps.googleusercontent.com',
    iosClientId: '491693754365-biugaibgovknh1flg9qufg8266ih4uj4.apps.googleusercontent.com',
    iosBundleId: 'com.example.admineventpro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDzJskK6m9KF9yVNIzxvI7TTSwPGx0Le0s',
    appId: '1:491693754365:web:a01285d4cb7ebebec5fb94',
    messagingSenderId: '491693754365',
    projectId: 'event-management-f73f5',
    authDomain: 'event-management-f73f5.firebaseapp.com',
    storageBucket: 'event-management-f73f5.appspot.com',
  );

}