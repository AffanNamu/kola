import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../data/remote/firestore/user_firestore.dart';
import '../presentation/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FCMService {
  FCMService._();
  static bool _initialized = false;
  static StreamSubscription<String>? _tokenSubscription;
  static StreamSubscription<fb.User?>? _authSubscription;

  static Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((msg) {
      if (!context.mounted) return;
      final title = msg.notification?.title ?? 'Notification';
      final body = msg.notification?.body ?? '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title: $body')));
    });

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
      _tokenSubscription = messaging.onTokenRefresh.listen((token) {
        saveToken(token);
      });
      _authSubscription = auth.authStateChanges().listen((user) async {
        if (user == null) return;
        await saveToken(await messaging.getToken());
      });
    } catch (_) {
      _initialized = false;
    }
  }
}
