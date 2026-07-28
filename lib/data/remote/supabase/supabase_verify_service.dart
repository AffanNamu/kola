import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';

class SupabaseVerifyService {
  SupabaseVerifyService(this._dio);
  final Dio _dio;

  factory SupabaseVerifyService.withClient() =>
      SupabaseVerifyService(DioClient.create());

  Future<Map<String, dynamic>> verifyPaystack({
    required String baseUrl,
    required String reference,
  }) async {
    if (baseUrl.isEmpty) {
      throw const PaymentException(message: 'Missing SUPABASE_VERIFY_BASE_URL');
    }
    try {
      final res = await _dio.get(
        '$baseUrl/paystack-verify?reference=$reference',
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw PaymentException(message: 'Paystack verification failed.', originalError: e);
    }
  }

  Future<Map<String, dynamic>> verifyFlutterwave({
    required String baseUrl,
    required String transactionId,
  }) async {
    if (baseUrl.isEmpty) {
      throw const PaymentException(message: 'Missing SUPABASE_VERIFY_BASE_URL');
    }
    try {
      final res = await _dio.get(
        '$baseUrl/flutterwave-verify?transaction_id=$transactionId',
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw PaymentException(message: 'Flutterwave verification failed.', originalError: e);
    }
  }
}
