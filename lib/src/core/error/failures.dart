/// Base failure class for all errors
abstract class Failure {
  final String message;
  final String code;

  const Failure({
    required this.message,
    required this.code,
  });
}

/// Network failure (no internet, timeout, server error)
class NetworkFailure extends Failure {
  const NetworkFailure()
      : message('Network error. Please check your connection.'),
        code('network_error');
}

/// Server failure (HTTP error response)
class ServerFailure extends Failure {
  final int statusCode;

  const ServerFailure({
    required this.statusCode,
    String? message,
  }) : message(message ?? 'Server error: $statusCode'),
        code('server_failure');
}

/// Cache failure (local storage read/write error)
class CacheFailure extends Failure {
  const CacheFailure()
      : message('Cache error. Data could not be read/written.'),
        code('cache_error');
}

/// Auth failure (invalid credentials, session expired)
class AuthFailure extends Failure {
  const AuthFailure()
      : message('Authentication failed. Please try again.'),
        code('auth_failure');
}

/// Validation failure (input validation errors)
class ValidationFailure extends Failure {
  final Map<String, String> errors;

  const ValidationFailure({
    required this.errors,
  }) : message(
            errors.entries
                .map((e) => '${e.key}: ${e.value}')
                .join(', ')),
        code('validation_failure');
}

/// NotFound failure (resource not found)
class NotFoundFailure extends Failure {
  final String resource;

  const NotFoundFailure({
    required this.resource,
  }) : message('${resource} not found.'),
        code('not_found');
}