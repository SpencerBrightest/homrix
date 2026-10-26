// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(demoAuthSessionStore)
final demoAuthSessionStoreProvider = DemoAuthSessionStoreProvider._();

final class DemoAuthSessionStoreProvider
    extends
        $FunctionalProvider<
          DemoAuthSessionStore,
          DemoAuthSessionStore,
          DemoAuthSessionStore
        >
    with $Provider<DemoAuthSessionStore> {
  DemoAuthSessionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoAuthSessionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoAuthSessionStoreHash();

  @$internal
  @override
  $ProviderElement<DemoAuthSessionStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DemoAuthSessionStore create(Ref ref) {
    return demoAuthSessionStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoAuthSessionStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoAuthSessionStore>(value),
    );
  }
}

String _$demoAuthSessionStoreHash() =>
    r'ad17fa16934fecb6e0af9b220fe459383de9f9f9';

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
    r'48c97c287f28fa56f0f5e260ccb7f138fff0afc2';

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
