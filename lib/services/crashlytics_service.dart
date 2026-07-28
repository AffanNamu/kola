import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  CrashlyticsService._();

  static Future<void> initialize() async {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(true);
  }

  static Future<void> recordError(
    dynamic exception,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }

  static Future<void> setUserId(String? uid) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
  }
}
