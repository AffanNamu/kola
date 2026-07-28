import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/cloudinary_constants.dart';
import 'cloudinary_config.dart';

class CloudinaryService {
  CloudinaryService(this._dio);

  final Dio _dio;

  factory CloudinaryService.withClient() {
    return CloudinaryService(DioClient.create());
  }

  Future<String> uploadImage({
    required File file,
    required String folder,
    String? publicId,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'api_key': CloudinaryConfig.apiKey,
        'folder': folder,
        if (publicId != null && publicId.isNotEmpty) 'public_id': publicId,
      });

      final res = await _dio.post(
        CloudinaryConfig.uploadUrl(),
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final secureUrl = res.data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw const CloudinaryException(message: 'Upload failed.');
      }
      return secureUrl;
    } catch (e) {
      throw CloudinaryException(
        message: 'Failed to upload image. Please try again.',
        originalError: e,
      );
    }
  }

  static String productsFolder() => CloudinaryConstants.productsFolder;
  static String categoriesFolder() => CloudinaryConstants.categoriesFolder;
  static String bannersFolder() => CloudinaryConstants.bannersFolder;
  static String usersFolder() => CloudinaryConstants.usersFolder;
  static String reviewsFolder() => CloudinaryConstants.reviewsFolder;
}
