import 'dart:async';

import 'package:homrix/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:homrix/features/auth/domain/entities/user_profile.dart';
import 'package:homrix/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

@Riverpod(keepAlive: true)
AbstractAuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(Supabase.instance.client);
}

/// Restores and observes the Supabase session for the lifetime of the app.
@Riverpod(keepAlive: true)
class AuthStateController extends _$AuthStateController {
  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.authStateChanges.listen(
      (user) {
        state = AsyncData(
          user == null ? const Unauthenticated() : Authenticated(user),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
    ref.onDispose(() => unawaited(subscription.cancel()));

    final user = await repository.getCurrentUser();
    return user == null ? const Unauthenticated() : Authenticated(user);
  }

  /// Rechecks the session after an explicit refresh request.
  Future<void> checkAuthenticationStatus() async {
    state = const AsyncData(AuthLoading());
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      state = AsyncData(
        user == null ? const Unauthenticated() : Authenticated(user),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  /// Authenticates with the configured Supabase project.
  Future<void> login({required String email, required String password}) async {
    state = const AsyncData(AuthLoading());
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = AsyncData(Authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  /// Creates a Supabase account. Returns whether email verification is pending.
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncData(AuthLoading());
    try {
      final requiresEmailConfirmation = await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password, displayName: displayName);
      if (requiresEmailConfirmation) {
        state = const AsyncData(Unauthenticated());
      } else {
        final user = await ref.read(authRepositoryProvider).getCurrentUser();
        state = user == null
            ? const AsyncData(Unauthenticated())
            : AsyncData(Authenticated(user));
      }
      return requiresEmailConfirmation;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  /// Revokes the Supabase session and returns to the login route.
  Future<void> logout() async {
    state = const AsyncData(AuthLoading());
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(Unauthenticated());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
