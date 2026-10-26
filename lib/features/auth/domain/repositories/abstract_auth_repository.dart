import 'package:homrix/features/auth/domain/entities/user_profile.dart';

/// Authentication operations required by the app, independent of Supabase.
abstract interface class AbstractAuthRepository {
  /// Emits the current signed-in user whenever the Supabase session changes.
  Stream<UserProfile?> get authStateChanges;

  Future<UserProfile?> getCurrentUser();

  Future<UserProfile> signIn({required String email, required String password});

  /// Returns true when the new account must verify its email before sign-in.
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}
