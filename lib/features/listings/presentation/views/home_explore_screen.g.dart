// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_explore_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod-managed state for explore categories, favorites, and bottom tabs.

@ProviderFor(ExploreShellController)
final exploreShellControllerProvider = ExploreShellControllerProvider._();

/// Riverpod-managed state for explore categories, favorites, and bottom tabs.
final class ExploreShellControllerProvider
    extends $NotifierProvider<ExploreShellController, ExploreShellState> {
  /// Riverpod-managed state for explore categories, favorites, and bottom tabs.
  ExploreShellControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreShellControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreShellControllerHash();

  @$internal
  @override
  ExploreShellController create() => ExploreShellController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreShellState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreShellState>(value),
    );
  }
}

String _$exploreShellControllerHash() =>
    r'1302ab54050cbc8df9c7af4e03c077d185fb5939';

/// Riverpod-managed state for explore categories, favorites, and bottom tabs.

abstract class _$ExploreShellController extends $Notifier<ExploreShellState> {
  ExploreShellState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExploreShellState, ExploreShellState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExploreShellState, ExploreShellState>,
              ExploreShellState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
