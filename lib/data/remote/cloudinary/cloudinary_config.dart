import '../../../core/constants/cloudinary_constants.dart';

class CloudinaryConfig {
  CloudinaryConfig._();

  static String get cloudName => CloudinaryConstants.cloudName;
  static String get apiKey => CloudinaryConstants.apiKey;
  static String get uploadPreset => CloudinaryConstants.uploadPreset;

  static String uploadUrl() =>
      '${CloudinaryConstants.baseUrl}/$cloudName/image/upload';
}
