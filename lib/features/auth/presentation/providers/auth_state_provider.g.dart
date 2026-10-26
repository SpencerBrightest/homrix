// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<
          AbstractAuthRepository,
          AbstractAuthRepository,
          AbstractAuthRepository
        >
    with $Provider<AbstractAuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AbstractAuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AbstractAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AbstractAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AbstractAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'857215da09a23907c2a147bc0fc7e450e5d551ad';

/// Coordinates session restoration, demo login, and logout state transitions.

@ProviderFor(AuthStateController)
final authStateControllerProvider = AuthStateControllerProvider._();

/// Coordinates session restoration, demo login, and logout state transitions.
final class AuthStateControllerProvider
    extends $AsyncNotifierProvider<AuthStateController, AuthState> {
  /// Coordinates session restoration, demo login, and logout state transitions.
  AuthStateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateControllerHash();

  @$internal
  @override
  AuthStateController create() => AuthStateController();
}

String _$authStateControllerHash() =>
    r'7b7c4b036a40fc2b016d3a40d611758807551b78';

/// Coordinates session restoration, demo login, and logout state transitions.

abstract class _$AuthStateController extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
