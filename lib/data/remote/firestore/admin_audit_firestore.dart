import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuditFirestore {
  const AdminAuditFirestore();

  Future<void> log({
    required String action,
    String? targetUid,
    Map<String, dynamic> details = const {},
  }) async {
    final actor = FirebaseAuth.instance.currentUser?.uid;
    if (actor == null) return;
    await FirebaseFirestore.instance.collection('adminActivityLogs').add({
      'actorUid': actor,
      'action': action,
      if (targetUid != null) 'targetUid': targetUid,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
