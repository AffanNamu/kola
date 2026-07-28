class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class PaymentException extends AppException {
  const PaymentException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class CloudinaryException extends AppException {
  const CloudinaryException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class StockException extends AppException {
  const StockException({
    required super.message,
    super.code,
    super.originalError,
  });
}
