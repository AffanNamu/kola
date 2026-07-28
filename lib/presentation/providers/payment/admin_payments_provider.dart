import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment/payment_model.dart';
import '../../../data/remote/firestore/admin_payments_firestore.dart';

final adminPaymentsFirestoreProvider = Provider<AdminPaymentsFirestore>((ref) {
  return const AdminPaymentsFirestore();
});

final adminPaymentsProvider = StreamProvider<List<PaymentModel>>((ref) {
  final fs = ref.read(adminPaymentsFirestoreProvider);
  return fs.watchAllPayments();
});

final paymentByIdProvider =
    FutureProvider.family<PaymentModel?, String>((ref, id) async {
  final fs = ref.read(adminPaymentsFirestoreProvider);
  return fs.getById(id);
});
