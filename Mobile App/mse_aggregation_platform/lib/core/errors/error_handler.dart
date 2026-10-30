import 'package:dio/dio.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException handle(Object error) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(message: 'Request timed out. Please try again.');
        case DioExceptionType.connectionError:
          return const NetworkException();
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data       = error.response?.data;
          final serverMsg  = (data is Map) ? (data['error'] ?? data['message']) as String? : null;

          switch (statusCode) {
            case 400:
              return AppException(message: serverMsg ?? 'Invalid request. Please check your input.', statusCode: 400);
            case 401:
              return const UnauthorizedException();
            case 403:
              return AppException(message: serverMsg ?? 'You do not have permission.', statusCode: 403);
            case 404:
              return const NotFoundException();
            case 409:
              final code = (data is Map) ? data['code'] as String? : null;
              return ConflictException(message: serverMsg ?? 'A conflict occurred.', code: code);
            case 422:
              final code = (data is Map) ? data['code'] as String? : null;
              return ValidationException(message: serverMsg ?? 'Validation failed.', code: code);
            default:
              return const ServerException();
          }
        default:
          return const NetworkException();
      }
    }
    return AppException(message: error.toString());
  }
}
