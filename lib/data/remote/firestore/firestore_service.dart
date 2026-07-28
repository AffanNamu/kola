import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> doc(
    String collection,
    String id,
  ) {
    return db.collection(collection).doc(id);
  }

  static CollectionReference<Map<String, dynamic>> col(String collection) {
    return db.collection(collection);
  }

  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction tx) action,
  ) {
    return db.runTransaction(action);
  }

  static WriteBatch batch() => db.batch();

  static FieldValue serverTimestamp() => FieldValue.serverTimestamp();

  static Timestamp nowTimestamp() => Timestamp.now();
}
