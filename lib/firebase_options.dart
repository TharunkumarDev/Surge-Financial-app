// File generated manually from google-services.json
// This file configures Firebase for the Flutter app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBFOIlHpaJE2Z78uOV6lT_6jYEFvFj4Sc',
    appId: '1:1031859674737:android:01d9a3df502861019945d0',
    messagingSenderId: '1031859674737',
    projectId: 'surge-financial-tracking-app',
    storageBucket: 'surge-financial-tracking-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBFOIlHpaJE2Z78uOV6lT_6jYEFvFj4Sc',
    appId: '1:1031859674737:ios:01d9a3df502861019945d0',
    messagingSenderId: '1031859674737',
    projectId: 'surge-financial-tracking-app',
    storageBucket: 'surge-financial-tracking-app.firebasestorage.app',
    iosBundleId: 'com.example.expenseTrackerPro',
  );
}
