import '../../../core/constants/payment_constants.dart';

class PaystackConfig {
  PaystackConfig._();

  static String get publicKey => PaymentConstants.paystackPublicKey;
  static const String verifyEndpoint = '/transaction/verify/';
}
