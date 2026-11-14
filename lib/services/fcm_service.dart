import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../data/remote/firestore/user_firestore.dart';
import '../presentation/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FCMService {
  FCMService._();

  static Future<void> initialize(BuildContext context) async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    // Foreground handler
    FirebaseMessaging.onMessage.listen((msg) {
      final title = msg.notification?.title ?? 'Notification';
      final body = msg.notification?.body ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title: $body')),
      );
    });

    // Get token and store to Firestore if logged in
    try {
      final container = ProviderScope.containerOf(context);
      final auth = container.read(firebaseAuthProvider);
      const userFs = UserFirestore();

      Future<void> saveToken(String? token) async {
        final uid = auth.currentUser?.uid;
        if (uid == null || token == null || token.isEmpty) return;
        await userFs.updateFcmToken(uid: uid, token: token);
      }

      await saveToken(await messaging.getToken());
      messaging.onTokenRefresh.listen((token) {
        saveToken(token);
      });
    } catch (_) {
      // silent
    }
  }
}
