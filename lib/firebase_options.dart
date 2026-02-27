import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // ── PASTE YOUR VALUES FROM THE FIREBASE CONSOLE BELOW ──────────────────────
  // Replace each 'YOUR_...' with the actual values shown in your firebase_options.dart

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_BRKTNl3sY0dk2WH85odAgMXx2L5w-CY',
    appId: '1:1007827805106:android:d9064fc3af982856097aab',
    messagingSenderId: '1007827805106',
    projectId: 'todoflow-ecd8d',
    storageBucket: 'todoflow-ecd8d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDigey7qrgB7DM_NXPESRbRrZgZMkk01eA',
    appId: '1:1007827805106:ios:139b38b64e02ada9097aab',
    messagingSenderId: '1007827805106',
    projectId: 'todoflow-ecd8d',
    storageBucket: 'todoflow-ecd8d.firebasestorage.app',
    iosBundleId: 'com.example.todoflow',
  );
}