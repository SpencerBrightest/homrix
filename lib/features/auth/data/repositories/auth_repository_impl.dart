import 'package:homrix/features/auth/domain/entities/user_profile.dart';
import 'package:homrix/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed email/password auth adapter.
class AuthRepositoryImpl implements AbstractAuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<UserProfile?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((change) {
        final user = change.session?.user;
        return user == null ? null : _toProfile(user);
      });

  UserProfile _toProfile(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayNameValue = metadata['display_name'];
    final displayName = displayNameValue is String ? displayNameValue : null;
    final role = user.appMetadata['role'] == 'admin'
        ? AccountRole.admin
        : AccountRole.user;
    return UserProfile(
      id: user.id,
      displayName: displayName?.trim().isNotEmpty == true
          ? displayName!
          : user.email?.split('@').first ?? 'Homrix Guest',
      email: user.email,
      role: role,
    );
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    return user == null ? null : _toProfile(user);
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign-in did not return a user.');
    }
    return _toProfile(user);
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'display_name': displayName.trim(),
        // This user-editable metadata is informational only. The trusted role
        // comes from app_metadata, set by the database trigger.
        'role': 'user',
      },
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign-up did not return a user.');
    }

    if (response.session != null) return false;
    return true;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
