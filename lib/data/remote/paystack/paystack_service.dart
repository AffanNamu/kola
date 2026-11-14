import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class PaystackService {
  PaystackService(this._dio);
  final Dio _dio;

  factory PaystackService.withClient() => PaystackService(DioClient.create());

  // NOTE: Paystack verify endpoint requires SECRET key in Authorization header.
  // We cannot safely do that in a client app.
  //
  // Instead, payment references remain unverified until a trusted backend
  // verifies them.
  Future<Map<String, dynamic>> verifyNotSupportedOnClient() async {
    throw const PaymentException(
      message:
          'Paystack verification requires secret key. Not supported on client in bootstrap mode.',
    );
  }

  Future<Map<String, dynamic>> verifyViaProxy({
    required String proxyUrl,
    required String reference,
  }) async {
    try {
      final res = await _dio.get(
        '$proxyUrl/verify/paystack/$reference',
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw PaymentException(message: 'Failed to verify payment.', originalError: e);
    }
  }
}
