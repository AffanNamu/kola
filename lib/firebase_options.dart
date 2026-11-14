// Generated from the Firebase project configuration for Kola.
// Android configuration: kola-7523f (com.nassaracoretechs.kola).
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Kola Firebase is configured for Android only.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase has not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXvHHo53alE8jqHyx18AIEddjdYgE7vd0',
    appId: '1:507347665820:android:a602b2acc216d54f8b7e59',
    messagingSenderId: '507347665820',
    projectId: 'kola-7523f',
    storageBucket: 'kola-7523f.firebasestorage.app',
  );
}
