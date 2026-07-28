import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/analytics/admin_analytics_model.dart';
import '../../../data/remote/firestore/admin_analytics_firestore.dart';

final adminAnalyticsFirestoreProvider = Provider<AdminAnalyticsFirestore>((ref) {
  return const AdminAnalyticsFirestore();
});

final adminAnalyticsProvider = StreamProvider<AdminAnalyticsModel>((ref) {
  final fs = ref.read(adminAnalyticsFirestoreProvider);
  return fs.watch();
});
