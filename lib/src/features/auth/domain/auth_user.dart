/// Domain model for authenticated user
///
/// Extends Equatable for value comparison and automatic
/// state equality checking in Riverpod FSM
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final AuthRole role;
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

  /// Copy with mutation-friendly pattern
  AuthUser copyWith({
    String? email,
    String? displayName,
    AuthRole? role,
    bool? isEmailVerified,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) => AuthUser(
    id: id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    lastLogin: lastLogin ?? this.lastLogin,
    createdAt: createdAt ?? this.createdAt,
  );

  /// Role-based access check
  bool can(List<AuthRole> roles) => roles.contains(this.role);

  /// Shortcut booleans for UI role checks
  bool get isGuest => role == AuthRole.guest;
  bool get isHost => role == AuthRole.host;
  bool get isAdmin => role == AuthRole.admin;

  /// Full name or email display
  String get displayOrEmail => displayName ?? email;

  @override
  List<Object> get props =>
      [id, email, displayName, role, isEmailVerified, lastLogin, createdAt];

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, role: $role)';
}