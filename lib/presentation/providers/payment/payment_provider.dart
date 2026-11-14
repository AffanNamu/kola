import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

final paymentFirestoreProvider = Provider<PaymentFirestore>((ref) {
  return const PaymentFirestore();
});

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<void>>((ref) {
  return PaymentController();
});

class PaymentController extends StateNotifier<AsyncValue<void>> {
  PaymentController() : super(const AsyncData(null));

  Future<String> createPendingPaymentForOrder({
    required String orderId,
    required String gateway,
    required String reference,
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

  Future<void> verifyPaymentWithGateway({
    required String paymentId,
    String? transactionId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await FirebaseFunctions.instance
          .httpsCallable('verifyPayment')
          .call<Map<String, dynamic>>({'paymentId': paymentId, if (transactionId != null && transactionId.isNotEmpty) 'transactionId': transactionId});
      if (result.data['success'] != true || result.data['status'] != 'success') {
        throw Exception('The payment gateway has not confirmed this transaction.');
      }
    });
  }

}
