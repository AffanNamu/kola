import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../data/models/payment/payment_model.dart';
import '../../../data/remote/firestore/checkout_transaction_service.dart';
import '../../../data/remote/firestore/payment_firestore.dart';
import '../../../data/repositories/payment_repository_impl.dart';
import '../../../data/remote/supabase/supabase_verify_service.dart';
import '../auth/auth_provider.dart';
import '../order/order_provider.dart';

final paymentFirestoreProvider = Provider<PaymentFirestore>((ref) {
  return const PaymentFirestore();
});

final paymentRepositoryProvider = Provider<PaymentRepositoryImpl>((ref) {
  return PaymentRepositoryImpl(ref.read(paymentFirestoreProvider));
});

final checkoutTxProvider = Provider<CheckoutTransactionService>((ref) {
  return const CheckoutTransactionService();
});

final supabaseVerifyServiceProvider = Provider<SupabaseVerifyService>((ref) {
  return SupabaseVerifyService.withClient();
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
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) throw Exception('Not logged in');

    state = const AsyncLoading();

    String paymentId = '';
    state = await AsyncValue.guard(() async {
      final payment = PaymentModel(
        id: '',
        orderId: orderId,
        userId: user.uid,
        gateway: gateway,
        reference: reference,
        status: 'pending',
        amount: amount,
        currency: currency,
        verified: false,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Atomic create + link
      final tx = ref.read(checkoutTxProvider);
      paymentId = await tx.createPaymentAndLinkOrder(
        payment: payment,
        gateway: gateway,
        reference: reference,
      );
    });

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
      final baseUrl = SupabaseConstants.verifyBaseUrl;
      final verifier = ref.read(supabaseVerifyServiceProvider);

      Map<String, dynamic> verifyResponse;

      if (gateway == 'paystack') {
        verifyResponse = await verifier.verifyPaystack(
          baseUrl: baseUrl,
          reference: referenceOrTransactionId,
        );
      } else if (gateway == 'flutterwave') {
        verifyResponse = await verifier.verifyFlutterwave(
          baseUrl: baseUrl,
          transactionId: referenceOrTransactionId,
        );
      } else {
        throw Exception('Unknown gateway: $gateway');
      }

      final ok = verifyResponse['success'] == true;
      final status = (verifyResponse['status'] ?? '').toString();

      final payRepo = ref.read(paymentRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);

      if (ok && status == 'success') {
        final f1 = await payRepo.updateStatus(
          paymentId: paymentId,
          status: 'success',
          verified: true,
          gatewayResponse: verifyResponse,
        );
        if (f1 != null) throw Exception(f1.message);

        final f2 = await orderRepo.updateStatus(orderId: orderId, status: 'paid');
        if (f2 != null) throw Exception(f2.message);
      } else {
        final f1 = await payRepo.updateStatus(
          paymentId: paymentId,
          status: 'failed',
          verified: false,
          gatewayResponse: verifyResponse,
        );
        if (f1 != null) throw Exception(f1.message);
      }
    });
  }

  Future<void> adminMarkPaid({
    required String orderId,
    required String paymentId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final payRepo = ref.read(paymentRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);

      final f1 = await payRepo.updateStatus(
        paymentId: paymentId,
        status: 'success',
        verified: true,
        gatewayResponse: {'manual': true},
      );
      if (f1 != null) throw Exception(f1.message);

      final f2 = await orderRepo.updateStatus(orderId: orderId, status: 'paid');
      if (f2 != null) throw Exception(f2.message);
    });
  }
}
