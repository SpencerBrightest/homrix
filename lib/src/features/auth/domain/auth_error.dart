/// Authentication error model
///
/// All auth errors implement a consistent code/message pattern
/// so the UI can display appropriate messages via the FSM
class AuthError extends Equatable {
  final String code;
  final String message;
  final int? statusCode;

  const AuthError({
    required this.code,
    required this.message,
    this.statusCode,
  });

  /// Common auth error types
  static const invalidCredential = AuthError(
    code: 'invalid_credential',
    message: 'Invalid email or password',
  );

  static const userNotFound = AuthError(
    code: 'user_not_found',
    message: 'No user found with this email',
  );

  static const networkError = AuthError(
    code: 'network_error',
    message: 'Network error. Please check your connection.',
  );

  static const tooManyRequests = AuthError(
    code: 'too_many_requests',
    message: 'Too many attempts. Please try again later.',
  );

  static const weakPassword = AuthError(
    code: 'weak_password',
    message: 'Password should be at least 6 characters',
  );

  @override
  List<Object> get props => [code, message, statusCode];

  @override
  String toString() => 'AuthError(code: $code, message: $message)';
}