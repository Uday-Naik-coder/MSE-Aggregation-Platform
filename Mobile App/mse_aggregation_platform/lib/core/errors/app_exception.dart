class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Unable to connect to the server. Please check your internet connection.'});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Your session has expired. Please log in again.', super.statusCode = 401});
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'You do not have permission to perform this action.', super.statusCode = 403});
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'The requested resource was not found.', super.statusCode = 404});
}

class ConflictException extends AppException {
  const ConflictException({required super.message, super.statusCode = 409, super.code});
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.statusCode = 422, super.code});
}

class ServerException extends AppException {
  const ServerException({super.message = 'Something went wrong on the server. Please try again.', super.statusCode = 500});
}
