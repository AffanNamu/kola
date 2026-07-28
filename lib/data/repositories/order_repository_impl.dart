import '../../core/errors/error_handler.dart';
import '../../core/errors/failure.dart';
import '../models/order/order_model.dart';
import '../remote/firestore/order_firestore.dart';

class OrderRepositoryImpl {
  OrderRepositoryImpl(this._orderFs);
  final OrderFirestore _orderFs;

  Stream<List<OrderModel>> watchMyOrders(String userId) =>
      _orderFs.watchMyOrders(userId);

  Stream<List<OrderModel>> watchAdminOrders() => _orderFs.watchAdminOrders();

  Future<(String?, Failure?)> create(OrderModel order) async {
    try {
      final id = await _orderFs.createOrder(order);
      return (id, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<Failure?> updateStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? courierName,
  }) async {
    try {
      await _orderFs.updateStatus(
        orderId: orderId,
        status: status,
        trackingNumber: trackingNumber,
        courierName: courierName,
      );
      return null;
    } catch (e) {
      return ErrorHandler.handleException(e);
    }
  }
}
