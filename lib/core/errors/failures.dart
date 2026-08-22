/// Base Failure class used across domain and presentation layers
abstract class Failure {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;
}

/// Server or API failure representation
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server failure occurred. Please try again.',
    super.code,
  });
}

/// Local storage or cache failure representation
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache failure occurred.',
    super.code,
  });
}

/// Validation failure representation
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Invalid input data provided.',
    super.code,
  });
}

/// Authentication failure representation
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failure.',
    super.code,
  });
}

/// Not found failure representation
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Requested entity not found.',
    super.code,
  });
}

/// Network failure representation
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failure.',
    super.code,
  });
}
