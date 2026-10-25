# Authentication & Onboarding

## Auth State as Riverpod FSM

All authentication state modeled as deterministic Finite State Machine via sealed classes.

### Auth FSM Sealed Class

```dart
// Auth state - zero unhandled UI boundary states
abstract class AuthState implements FSM<AuthState> {
  final AuthStatus status;
  final AuthUser? user;
  final AuthError? error;
  final AuthSession? session;

  const AuthState._({
    required this.status,
    this.user,
    this.error,
    this.session,
  });

  factory AuthState.unknown() => const AuthState._(
        status: AuthStatus.unknown,
      );

  factory AuthState.unauthenticated() => const AuthState._(
        status: AuthStatus.unauthenticated,
      );

  factory AuthState.authenticating() => const AuthState._(
        status: AuthStatus.authenticating,
      );

  factory AuthState.authenticated({
    required AuthUser user,
    required AuthSession session,
  }) => AuthState._(
        status: AuthStatus.authenticated,
        user: user,
        session: session,
      );

  factory AuthState.failure({
    required AuthError error,
  }) => AuthState._(
        status: AuthStatus.failure,
        error: error,
      );

  @override
  AuthStatus get status => status;

  @override
  bool get isUnknown => status == AuthStatus.unknown;

  @override
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  @override
  bool get isAuthenticating => status == AuthStatus.authenticating;

  @override
  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  bool get isFailure => status == AuthStatus.failure;

  @override
  String toString() => 'AuthState(status: $status, user: $user)';
}
```

### Auth Status Enum

```dart
enum AuthStatus {
  unknown,     // Initial state before platform channel ready
  unauthenticated, // User not logged in
  authenticating, // Logging in / verifying biometric
  authenticated,   // Logged in, session active
  failure,       // Auth failed - retry or logout
}
```

### Auth User Model

```dart
class AuthUser {
  final String id;
  final String email;
  final String? displayName;
  final UserRole role; // guest, host, admin
  final bool isEmailVerified;
  final DateTime lastLogin;
  final DateTime createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    required this.isEmailVerified,
    required this.lastLogin,
    required this.createdAt,
  });

  factory AuthUser.fromFirebase(User firebaseUser) => AuthUser(
    id: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    displayName: firebaseUser.displayName,
    role: _mapRole(firebaseUser.customClaims?['role'] ?? 'guest'),
    isEmailVerified: firebaseUser.isEmailVerified,
    lastLogin: firebaseUser.metadata.lastLogin ?? DateTime.now(),
    createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
  );

  AuthUser copyWith({
    String? email,
    String? displayName,
    UserRole? role,
    bool? isEmailVerified,
    DateTime? lastLogin,
  }) => AuthUser(
    id: id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    lastLogin: lastLogin ?? this.lastLogin,
    createdAt: createdAt,
  );

  UserRole getRole() => role;
}

UserRole _mapRole(dynamic claim) {
  if (claim == 'admin') return UserRole.admin;
  if (claim == 'host') return UserRole.host;
  return UserRole.guest;
}
```

### Riverpod Auth Provider

```dart
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    authRepository: ref.read(authRepositoryProvider),
    userRepository: ref.read(userRepositoryProvider),
  ),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthNotifier({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepo = authRepository,
        _userRepo = userRepository,
        super(AuthState.unknown());

  // 1. Initialize - check persistent session on app start
  Future<void> initialize() async {
    final session = await _authRepo.getPersistentSession();
    
    if (session == null) {
      state = AuthState.unauthenticated();
      return;
    }

    // 2. Validate session with server
    final valid = await _authRepo.validateSession(session.token);
    
    if (!valid) {
      // Clear invalid session, start fresh
      await _authRepo.clearSession();
      state = AuthState.unauthenticated();
      return;
    }

    // 3. Map Firebase user to domain model
    final user = await _userRepo.getUserById(session.uid);
    state = AuthState.authenticated(
      user: user,
      session: session,
    );
  }

  // 2. Login with email/password
  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = AuthState.authenticating();

    final result = await _authRepo.signInWithEmail(email, password);

    result.fold(
      (failure) => state = AuthState.failure(
        error: AuthError(
          code: failure.code,
          message: failure.message,
        ),
      ),
      (session) async {
        // 3. Save persistently (shared prefs / secure storage)
        await _authRepo.savePersistentSession(session);
        
        // 4. Fetch user profile
        final user = await _userRepo.getOrCreateUser(
          uid: session.userId,
          email: session.email,
        );
        
        state = AuthState.authenticated(
          user: user,
          session: session,
        );
      },
    );
  }

  // 3. Login with biometric (local auth only, re-validates server session)
  Future<void> loginWithBiometric() async {
    final canAuthenticate = await _biometricAuth.canCheckBiometrics;
    
    if (!canAuthenticate) {
      state = AuthState.failure(
        error: const AuthError(
          code: 'biometric_not_available',
          message: 'Biometric authentication not available on this device',
        ),
      );
      return;
    }

    final authenticated = await _biometricAuth.authenticate(
      localizedReason: 'Log in to your Airbnb account',
    );

    if (authenticated) {
      // Biometric succeeded - re-use existing persistent session
      await initialize();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  // 4. Logout - clear session, reactive UI transition
  Future<void> logout() async {
    await _authRepo.clearSession();
    state = AuthState.unauthenticated();
  }

  // 5. Refresh session before expiry
  Future<void> refreshSession() async {
    final currentSession = state.when(
      authenticated: (user, session) => session,
      orElse: () => throw StateError('Not authenticated'),
    );

    final refreshed = await _authRepo.refreshSession(currentSession.refreshToken);

    refreshed.fold(
      (failure) => state = AuthState.failure(
        error: AuthError(
          code: failure.code,
          message: 'Session refresh failed',
        ),
      ),
      (newSession) async {
        await _authRepo.savePersistentSession(newSession);
        // User profile stays the same, only session updates
        state = AuthState.authenticated(
          user: state.user,
          session: newSession,
        );
      },
    );
  }
}
```

### Pull-to-Refresh Auth Flow

```
┌─────────────────────────────────────────────────────────────┐
│                 AUTH SESSION REFRESH FLOW                     │
├─────────────────────────────────────────────────────────────┤
│  1. User pulls down on any screen OR app goes to background → foreground │
│  │                                                             │
│  ▼                                                             │
│  2. ref.invalidate(authStateProvider) OR native didEnterForeground │
│  │                                                             │
│  ▼                                                             │
│  3. AuthNotifier.initialize() triggered                       │
│  │                                                             │
│  ▼                                                             │
│  4. Get persistent session from shared_prefs / secure_storage │
│  │                                                             │
│  ▼                                                             │
│  5. Validate session with: POST /api/auth/verify {token}       │
│  │                                                             │
│  ▼                                                             │
│  6. If valid → AuthState.authenticated() → UI updates        │
│  │                       ▲                                       │
│  │                       │                                       │
│  ▼                       │                                       │
│  7. If invalid → clear session → AuthState.unauthenticated() │
│  └─────────────────────────────────────────────────────────────┘
```

### Role-Based Access Control

```dart
enum UserRole { guest, host, admin }

// Extension for easy RBAC checks in UI
extension AuthRole on AuthUser {
  bool can(List<UserRole> roles) => roles.contains(this.role);
  
  bool get isGuest => role == UserRole.guest;
  bool get isHost => role == UserRole.host;
  bool get isAdmin => role == UserRole.admin;
  
  // Access control helpers
  bool canManageListings() => role.isHost;
  bool canApproveBookings() => role.isHost;
  bool canViewAnalytics() => role.isAdmin;
  bool canRevokeUser() => role.isAdmin;
  bool canListProperties() => role.isGuest || role.isHost;
  bool canBookProperties() => role.isGuest;
}
```

### UI Consumption Pattern

```dart
// Any widget - forces exhaustive state handling
Widget buildAuthUI(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    unknown: () => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    unauthenticated: () => const AuthGate(), // Login / Signup screen
    authenticating: () => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    authenticated: (user) => _buildScreenForRole(user),
    failure: (error) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${error.code}: ${error.message}'),
            ElevatedButton(
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Role-based screen routing
Widget _buildScreenForRole(AuthUser user) {
  if (user.isAdmin) {
    return const AdminDashboard();
  }
  if (user.isHost) {
    return const HostHome();
  }
  return const GuestHome();
}
```

### Session Persistence & Recovery

- ✅ **Shared preferences** (light): `isLoggedIn` flag, `userRole`
- ✅ **Secure storage** (Keystore / Keychain): `accessToken`, `refreshToken`, `uid`
- ✅ **Session TTL**: 30 days max; auto-refresh via `refreshSession()` on app foreground
- ✅ **On invalidation**: Clear all storage, navigate to login, emit `unauthenticated`
- ✅ **Biometric re-auth**: Does NOT create new session; re-validates existing persistent session