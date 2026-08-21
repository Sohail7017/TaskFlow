/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Thrown when an error occurs during server or mock API data fetching
class ServerException extends AppException {
  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.code,
  });
}

/// Thrown when an error occurs during local caching or local data access
class CacheException extends AppException {
  const CacheException({
    super.message = 'A local storage error occurred.',
    super.code,
  });
}

/// Thrown when input data validation fails
class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation failed for input data.',
    super.code,
  });
}

/// Thrown when authentication or authorization fails
class AuthenticationException extends AppException {
  const AuthenticationException({
    super.message = 'Authentication failed. Please sign in again.',
    super.code,
  });
}

/// Thrown when a requested resource or record cannot be found
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.code,
  });
}

/// Thrown when a network connectivity failure is encountered
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network connection failed. Please check your internet.',
    super.code,
  });
}
