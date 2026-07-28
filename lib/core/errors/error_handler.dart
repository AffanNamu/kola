import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'app_exception.dart';
import 'failure.dart';

class ErrorHandler {
  ErrorHandler._();

  static Failure handleException(dynamic exception) {
    if (exception is FirebaseAuthException) {
      return AuthFailure(
        message: _getFirebaseAuthMessage(exception.code),
        code: exception.code,
      );
    }

    if (exception is FirebaseException) {
      return FirestoreFailure(
        message: _getFirestoreMessage(exception.code ?? 'unknown'),
        code: exception.code,
      );
    }

    if (exception is DioException) {
      return NetworkFailure(
        message: _getDioMessage(exception),
        code: exception.response?.statusCode?.toString(),
      );
    }

    if (exception is AuthException) {
      return AuthFailure(message: exception.message, code: exception.code);
    }

    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    }

    if (exception is FirestoreException) {
      return FirestoreFailure(message: exception.message, code: exception.code);
    }

    if (exception is PaymentException) {
      return PaymentFailure(message: exception.message, code: exception.code);
    }

    if (exception is CloudinaryException) {
      return CloudinaryFailure(
          message: exception.message, code: exception.code);
    }

    if (exception is ValidationException) {
      return ValidationFailure(
          message: exception.message, code: exception.code);
    }

    if (exception is NotFoundException) {
      return NotFoundFailure(message: exception.message, code: exception.code);
    }

    if (exception is UnauthorizedException) {
      return UnauthorizedFailure(
          message: exception.message, code: exception.code);
    }

    if (exception is StockException) {
      return StockFailure(message: exception.message, code: exception.code);
    }

    if (exception is CacheException) {
      return CacheFailure(message: exception.message, code: exception.code);
    }

    return UnknownFailure(
      message: exception?.toString() ?? 'An unexpected error occurred',
    );
  }

  static String _getFirebaseAuthMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'account-exists-with-different-credential':
        return 'An account exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please log in again to complete this action.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _getFirestoreMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This record already exists.';
      case 'resource-exhausted':
        return 'Service is temporarily unavailable. Please try again later.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request timed out. Please check your connection.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'data-loss':
        return 'An error occurred with your data. Please try again.';
      default:
        return 'A database error occurred. Please try again.';
    }
  }

  static String _getDioMessage(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Try again.';
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        if (statusCode == 401) return 'Unauthorized. Please login again.';
        if (statusCode == 403) return 'Access denied.';
        if (statusCode == 404) return 'Resource not found.';
        if (statusCode == 500) return 'Server error. Please try again later.';
        return 'Network error (${statusCode}). Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.unknown:
        return 'An unexpected network error occurred.';
    }
  }
}
