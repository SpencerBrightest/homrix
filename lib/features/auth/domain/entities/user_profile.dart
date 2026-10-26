/// UI-safe identity data for the currently authenticated user.
final class UserProfile {
  const UserProfile({required this.id, required this.displayName, this.email});

  final String id;
  final String displayName;
  final String? email;
}
