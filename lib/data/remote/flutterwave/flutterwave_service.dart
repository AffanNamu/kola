import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class FlutterwaveService {
  FlutterwaveService(this._dio);
  final Dio _dio;

  factory FlutterwaveService.withClient() => FlutterwaveService(DioClient.create());

  // Flutterwave verification also requires secret key.
  Future<Map<String, dynamic>> verifyNotSupportedOnClient() async {
    throw const PaymentException(
      message:
          'Flutterwave verification requires secret key. Not supported on client in bootstrap mode.',
    );
  }

  Future<Map<String, dynamic>> verifyViaProxy({
    required String proxyUrl,
    required String transactionId,
  }) async {
    try {
      final res = await _dio.get(
        '$proxyUrl/verify/flutterwave/$transactionId',
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw PaymentException(message: 'Failed to verify payment.', originalError: e);
    }
  }
}
