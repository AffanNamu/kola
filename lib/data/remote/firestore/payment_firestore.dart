import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/payment/payment_model.dart';
import 'firestore_service.dart';

class PaymentFirestore {
  const PaymentFirestore();

  CollectionReference<Map<String, dynamic>> get _payments =>
      FirestoreService.col(FirestoreConstants.payments);

  Stream<List<PaymentModel>> watchMyPayments(String userId) {
    return _payments
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentModel.fromFirestore).toList());
  }

  Stream<List<PaymentModel>> watchPaymentsForOrder(String orderId) {
    return _payments
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentModel.fromFirestore).toList());
  }

  Stream<List<PaymentModel>> watchAllPayments({int limit = 100}) {
    return _payments
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentModel.fromFirestore).toList());
  }

  Future<PaymentModel?> getById(String paymentId) async {
    final doc = await _payments.doc(paymentId).get();
    if (!doc.exists) return null;
    return PaymentModel.fromFirestore(doc);
  }

  Future<String> createPayment(PaymentModel payment) async {
    final docRef = _payments.doc();
    final payload = payment.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(payload.toFirestore());
    return docRef.id;
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    bool? verified,
    Map<String, dynamic>? gatewayResponse,
  }) async {
    await _payments.doc(paymentId).set(
      {
        'status': status,
        if (verified != null) 'verified': verified,
        if (gatewayResponse != null) 'gatewayResponse': gatewayResponse,
        'updatedAt': FieldValue.serverTimestamp(),
        if (verified == true) 'verifiedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
