import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/analytics/admin_analytics_model.dart';
import 'firestore_service.dart';

class AdminAnalyticsFirestore {
  const AdminAnalyticsFirestore();

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirestoreService.col(FirestoreConstants.analytics).doc('adminDashboard');

  Stream<AdminAnalyticsModel> watch() {
    return _doc.snapshots().map((snap) {
      if (!snap.exists) {
        return const AdminAnalyticsModel();
      }
      final data = snap.data() ?? {};
      return AdminAnalyticsModel.fromJson({
        ...data,
        'revenue30d': (data['revenue30d'] as num?)?.toDouble() ?? 0.0,
      });
    });
  }

  Future<void> set(AdminAnalyticsModel model) async {
    await _doc.set(model.toJson(), SetOptions(merge: true));
  }
}
