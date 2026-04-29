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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBfLd5efwiA-wbuhK20_6Dq5fry7wBw6dQ',
    appId: '1:658277409136:android:a9bec92e9ab9e90842efb5',
    messagingSenderId: '658277409136',
    projectId: 'tsiwamahber',
    storageBucket: 'tsiwamahber.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfLd5efwiA-wbuhK20_6Dq5fry7wBw6dQ',
    appId: '1:658277409136:android:a9bec92e9ab9e90842efb5',
    messagingSenderId: '658277409136',
    projectId: 'tsiwamahber',
    storageBucket: 'tsiwamahber.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBfLd5efwiA-wbuhK20_6Dq5fry7wBw6dQ',
    appId: '1:658277409136:android:a9bec92e9ab9e90842efb5',
    messagingSenderId: '658277409136',
    projectId: 'tsiwamahber',
    storageBucket: 'tsiwamahber.firebasestorage.app',
    iosBundleId: 'com.example.tsiwaMahber',
  );
}
