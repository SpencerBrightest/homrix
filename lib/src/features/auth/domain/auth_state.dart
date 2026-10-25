import 'package:equatable/equatable.dart';

import 'auth_user.dart';
import 'auth_error.dart';

/// Auth state as a deterministic FSM (Finite State Machine)
/// Sealed class pattern ensures zero unhandled UI boundary states
abstract class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final AuthError? error;
  final DateTime? lastUpdated;

  const AuthState._({
    required this.status,
    this.user,
    this.error,
    this.lastUpdated,
  });

  /// Idle/initial state before auth check completes
  factory AuthState.unknown() => const AuthState._(
        status: AuthStatus.unknown,
      );

      /// User is not logged in
  factory AuthState.unauthenticated() => const AuthState._(
        status: AuthStatus.unauthenticated,
      );

      /// Auth process in progress (logging in / verifying biometric)
  factory AuthState.authenticating() => const AuthState._(
        status: AuthStatus.authenticating,
      );

      /// User is logged in with valid session
  factory AuthState.authenticated({
    required AuthUser user,
    required DateTime lastUpdated,
  }) => AuthState._(
        status: AuthStatus.authenticated,
        user: user,
        lastUpdated: lastUpdated,
      );

      /// Auth failed - show error in UI
  factory AuthState.failure({
    required AuthError error,
  }) => AuthState._(
        status: AuthStatus.failure,
        error: error,
      );

  /// Get the current status
  AuthStatus get status => status;

  /// Check if user is unauthenticated
  bool get isUnknown => status == AuthStatus.unknown;

  /// Check if user is not logged in
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Check if auth process is in progress
  bool get isAuthenticating => status == AuthStatus.authenticating;

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if auth failed
  bool get isFailure => status == AuthStatus.failure;

  /// Get the authenticated user
  AuthUser? get userValue => user;

  /// Get the error if any
  AuthError? get errorValue => error;

  /// Get last updated timestamp
  DateTime? get lastUpdatedValue => lastUpdated;

  @override
  List<Object?> get props => [status, user, error, lastUpdated];

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, error: $error)';
}