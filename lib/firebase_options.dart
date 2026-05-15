// Firebase configuration file generated for UniHub
// Contains environment-specific configuration for Firebase services.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyClD80P2K9zx_Qf3owm1Bj1FRKEJvFyfzQ',
    appId: '1:16581503358:web:e6f23e9369304d1b856b2f',
    messagingSenderId: '16581503358',
    projectId: 'notify-a0ffa',
    authDomain: 'notify-a0ffa.firebaseapp.com',
    storageBucket: 'notify-a0ffa.firebasestorage.app',
    measurementId: 'G-MF3KKR375L',
  );

  // TODO: Replace with your Firebase Web configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDndZQpAbgh_ecap-OA5WU-EYwTstVTQ9U',
    appId: '1:16581503358:android:6e69fbbb60665b0e856b2f',
    messagingSenderId: '16581503358',
    projectId: 'notify-a0ffa',
    storageBucket: 'notify-a0ffa.firebasestorage.app',
  );

  // TODO: Replace with your Firebase Android configuration

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMgzhPX3rVQRh6CjYBoOK-DxNv99nVVds',
    appId: '1:16581503358:ios:3663c4925ee8648f856b2f',
    messagingSenderId: '16581503358',
    projectId: 'notify-a0ffa',
    storageBucket: 'notify-a0ffa.firebasestorage.app',
    iosBundleId: 'com.example.unihub',
  );

  // TODO: Replace with your Firebase iOS configuration

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCMgzhPX3rVQRh6CjYBoOK-DxNv99nVVds',
    appId: '1:16581503358:ios:3663c4925ee8648f856b2f',
    messagingSenderId: '16581503358',
    projectId: 'notify-a0ffa',
    storageBucket: 'notify-a0ffa.firebasestorage.app',
    iosBundleId: 'com.example.unihub',
  );

  // TODO: Replace with your Firebase macOS configuration

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyClD80P2K9zx_Qf3owm1Bj1FRKEJvFyfzQ',
    appId: '1:16581503358:web:730fbfaae3cc7e33856b2f',
    messagingSenderId: '16581503358',
    projectId: 'notify-a0ffa',
    authDomain: 'notify-a0ffa.firebaseapp.com',
    storageBucket: 'notify-a0ffa.firebasestorage.app',
    measurementId: 'G-54F51WEVK5',
  );

  // TODO: Replace with your Firebase Windows configuration
}
