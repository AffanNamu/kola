import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/user/user_model.dart';
import 'firestore_service.dart';

class UserFirestore {
  const UserFirestore();

  CollectionReference<Map<String, dynamic>> get _users =>
      FirestoreService.col(FirestoreConstants.users);

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<void> createOrUpdateUser(UserModel user) async {
    final now = DateTime.now();
    final payload = user.copyWith(
      updatedAt: now,
      createdAt: user.createdAt ?? now,
    );

    await _users.doc(user.uid).set(
          payload.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> updateFcmToken({
    required String uid,
    required String token,
  }) async {
    await _users.doc(uid).set(
      {
        FirestoreConstants.fcmToken: token,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
