abstract class AppException implements Exception {
  String get message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  @override
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});
}

class AuthException extends AppException {
  @override
  final String message;

  AuthException(this.message);
}

class ValidationException extends AppException {
  @override
  final String message;
  final List<String> errors;

  ValidationException(this.message, {this.errors = const []});
}

class NotFoundException extends AppException {
  @override
  final String message;

  NotFoundException([this.message = 'Resource not found']);
}

class ForbiddenException extends AppException {
  @override
  final String message;

  ForbiddenException([this.message = 'Access denied']);
}

class RateLimitException extends AppException {
  @override
  final String message;
  final int retryAfter;

  RateLimitException(this.message, {this.retryAfter = 60});
}

class ServerException extends AppException {
  @override
  final String message;

  ServerException([this.message = 'Server error. Please try again later.']);
}
