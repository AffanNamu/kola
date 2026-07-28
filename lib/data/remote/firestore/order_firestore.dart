import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/order/order_model.dart';
import 'firestore_service.dart';

class OrderFirestore {
  const OrderFirestore();

  CollectionReference<Map<String, dynamic>> get _orders =>
      FirestoreService.col(FirestoreConstants.orders);

  Stream<List<OrderModel>> watchMyOrders(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Stream<List<OrderModel>> watchAdminOrders({int limit = 50}) {
    return _orders
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Future<OrderModel?> getById(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  Future<String> createOrder(OrderModel order) async {
    final docRef = _orders.doc();
    final payload = order.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(payload.toFirestore());
    return docRef.id;
  }

  Future<void> linkPayment({
    required String orderId,
    required String paymentId,
    required String gateway,
    required String reference,
  }) async {
    await _orders.doc(orderId).set(
      {
        'paymentId': paymentId,
        'paymentGateway': gateway,
        'paymentReference': reference,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? courierName,
  }) async {
    await _orders.doc(orderId).set(
      {
        'status': status,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (courierName != null) 'courierName': courierName,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
