import 'package:homrix/features/auth/domain/entities/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

/// Authentication flow states used by the router and presentation layer.
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final UserProfile user;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Minimal in-memory session store for the unaffiliated demo authentication.
///
/// Replace this store with the selected identity provider and secure session
/// persistence before using authentication as a production security boundary.
class DemoAuthSessionStore {
  UserProfile? _currentUser;

  Future<UserProfile?> readCurrentUser() async => _currentUser;

  Future<UserProfile> createDemoSession() async {
    const user = UserProfile(
      id: 'demo-user',
      displayName: 'Homrix Guest',
      email: 'guest@example.com',
    );
    _currentUser = user;
    return user;
  }

  Future<void> clearSession() async {
    _currentUser = null;
  }
}

@Riverpod(keepAlive: true)
DemoAuthSessionStore demoAuthSessionStore(Ref ref) {
  return DemoAuthSessionStore();
}

/// Coordinates session restoration, demo login, and logout state transitions.
@Riverpod(keepAlive: true)
class AuthStateController extends _$AuthStateController {
  @override
  Future<AuthState> build() async => const AuthInitial();

  /// Restores the current session from the local session store.
  Future<void> checkAuthenticationStatus() async {
    state = const AsyncData(AuthLoading());
    try {
      final user = await ref
          .read(demoAuthSessionStoreProvider)
          .readCurrentUser();
      state = AsyncData(
        user == null ? const Unauthenticated() : Authenticated(user),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  /// Creates a demo-only session; this does not authenticate real credentials.
  Future<void> login() async {
    state = const AsyncData(AuthLoading());
    try {
      final user = await ref
          .read(demoAuthSessionStoreProvider)
          .createDemoSession();
      state = AsyncData(Authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  /// Clears the demo session and returns the application to the login route.
  Future<void> logout() async {
    state = const AsyncData(AuthLoading());
    try {
      await ref.read(demoAuthSessionStoreProvider).clearSession();
      state = const AsyncData(Unauthenticated());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
