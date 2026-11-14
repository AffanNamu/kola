import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../data/remote/firestore/payment_firestore.dart';
import '../auth/auth_provider.dart';

final paymentFirestoreProvider = Provider<PaymentFirestore>((ref) {
  return const PaymentFirestore();
});

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<void>>((ref) {
  return PaymentController(ref);
});

class PaymentController extends StateNotifier<AsyncValue<void>> {
  PaymentController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<String> createPendingPaymentForOrder({
    required String orderId,
    required String gateway,
    required String reference,
    required double amount,
    String currency = 'USD',
    Map<String, dynamic> metadata = const {},
  }) async {
    state = const AsyncLoading();
    String paymentId = '';
    state = await AsyncValue.guard(() async {
      final result = await FirebaseFunctions.instance
          .httpsCallable('createPendingPayment')
          .call<Map<String, dynamic>>({
        'orderId': orderId,
        'gateway': gateway,
        'reference': reference,
      });
      paymentId = result.data['paymentId'] as String;
    });
    if (state.hasError) throw state.error!;
    return paymentId;
  }

  Future<void> verifyPaymentViaSupabase({
    required String paymentId,
    required String gateway,
    required String referenceOrTransactionId,
    required String orderId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await FirebaseFunctions.instance
          .httpsCallable('verifyPayment')
          .call<Map<String, dynamic>>({'paymentId': paymentId});
      if (result.data['success'] != true || result.data['status'] != 'success') {
        throw Exception('The payment gateway has not confirmed this transaction.');
      }
    });
  }

}
