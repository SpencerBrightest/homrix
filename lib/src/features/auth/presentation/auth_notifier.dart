import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_state.dart';
import '../domain/auth_user.dart';
../domain/auth_error.dart';
import '../data/auth_repository.dart';

/// Riverpod StateNotifier managing Auth FSM state
///
/// All UI consumes this provider via ref.watch(authStateProvider).when(...)
/// Compiler forces exhaustive state handling - zero unhandled boundary states
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(
          localDataSource: HiveLocalDataSource(),
          apiClient: ApiClient(),
        ),
        super(AuthState.unknown());

  /// Initialize - check persistent session on app start
  /// Called on app launch and on pull-to-refresh
  Future<void> initialize() async {
    // 1. Get persistent session from local storage
    final session = await _repository.getPersistentSession();

    if (session == null) {
      // No session - user is unauthenticated
      state = AuthState.unauthenticated();
      return;
    }

    // 2. Validate session with backend
    final valid = await _repository.validateSession(
      session['accessToken'] as String,
    );

    if (!valid) {
      // Invalid session - clear and start fresh
      await _repository.clearSession();
      state = AuthState.unauthenticated();
      return;
    }

    // 3. Fetch/ create user profile
    final user = await _repository.getOrCreateUser(
      uid: session['uid'] as String,
      email: session['email'] as String,
    );

    // 4. Emit authenticated state
    state = AuthState.authenticated(
      user: user,
      lastUpdated: DateTime.now(),
    );
  }

  /// Login with email/password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.authenticating(); // Transition to processing state

    try {
      final result = await _repository.signInWithEmail(
        email: email,
        password: password,
      );

      // 3. Fetch/ create user profile
      final user = await _repository.getOrCreateUser(
        uid: result['userId'] as String,
        email: result['email'] as String,
      );

      // 4. Emit authenticated state
      state = AuthState.authenticated(
        user: user,
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      // 5. Emit failure state with error
      state = AuthState.failure(
        error: error is AuthError
            ? error
            : AuthError(
                code: 'auth_failure',
                message: error.toString(),
              ),
      );
    }
  }

  /// Login with biometric (re-validates existing server session)
  Future<void> loginWithBiometric() async {
    // Biometric succeeds - re-use existing persistent session
    // Just re-initialize the auth state
    await initialize();
  }

  /// Logout - clear session and transition to unauthenticated
  Future<void> logout() async {
    await _repository.clearSession();
    state = AuthState.unauthenticated();
  }

  /// Refresh session before expiry
  Future<void> refreshSession() async {
    // Only can refresh if currently authenticated
    final currentState = state;

    if (!currentState.isAuthenticated) {
      // Not authenticated, re-initialize
      await initialize();
      return;
    }

    final refreshToken = currentState.userValue?.lastLogin
        .toString(); // In reality, fetch from session

    if (refreshToken == null) {
      await initialize();
      return;
    }

    final newSession = await _repository.refreshSession(
      refreshToken: refreshToken,
    );

    if (newSession != null && newSession['valid'] == true) {
      // Save new session
      await _repository.savePersistentSession(newSession);

      // Fetch user (stays the same, only session updates)
      final user = state.userValue;

      state = AuthState.authenticated(
        user: user,
        lastUpdated: DateTime.now(),
      );
    } else {
      // Refresh failed - clear session
      await _repository.clearSession();
      state = AuthState.unauthenticated();
    }
  }
}

/// Provider declaration - used across the app
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);