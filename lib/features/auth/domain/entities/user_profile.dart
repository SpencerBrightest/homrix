/// UI-safe identity data for the currently authenticated user.
enum AccountRole { user, admin }

final class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.email,
    this.role = AccountRole.user,
  });

  final String id;
  final String displayName;
  final String? email;

  /// Informational role from trusted Supabase app metadata, not UI authorization.
  final AccountRole role;
}
