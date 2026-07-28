import '../../models/payment/payment_model.dart';
import 'payment_firestore.dart';

class AdminPaymentsFirestore {
  const AdminPaymentsFirestore();

  Stream<List<PaymentModel>> watchAllPayments({int limit = 100}) {
    return const PaymentFirestore().watchAllPayments(limit: limit);
  }

  Future<PaymentModel?> getById(String paymentId) {
    return const PaymentFirestore().getById(paymentId);
  }
}
