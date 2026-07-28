import '../../core/errors/error_handler.dart';
import '../../core/errors/failure.dart';
import '../models/payment/payment_model.dart';
import '../remote/firestore/payment_firestore.dart';

class PaymentRepositoryImpl {
  PaymentRepositoryImpl(this._paymentFs);
  final PaymentFirestore _paymentFs;

  Future<(String?, Failure?)> create(PaymentModel payment) async {
    try {
      final id = await _paymentFs.createPayment(payment);
      return (id, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<Failure?> updateStatus({
    required String paymentId,
    required String status,
    bool? verified,
    Map<String, dynamic>? gatewayResponse,
  }) async {
    try {
      await _paymentFs.updatePaymentStatus(
        paymentId: paymentId,
        status: status,
        verified: verified,
        gatewayResponse: gatewayResponse,
      );
      return null;
    } catch (e) {
      return ErrorHandler.handleException(e);
    }
  }
}
