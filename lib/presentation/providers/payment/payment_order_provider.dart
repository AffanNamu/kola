import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment/payment_model.dart';
import '../../../data/remote/firestore/payment_firestore.dart';

final paymentsForOrderProvider =
    StreamProvider.family<List<PaymentModel>, String>((ref, orderId) {
  return const PaymentFirestore().watchPaymentsForOrder(orderId);
});
