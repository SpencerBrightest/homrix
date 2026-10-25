import 'package:equatable/equatable.dart';

import 'listing.dart';

/// Search state as a deterministic FSM (Finite State Machine)
/// Sealed class pattern ensures zero unhandled UI boundary states
/// UI must consume via .when(idle:, loading:, success:, failure:)
abstract class SearchState extends Equatable {
  final SearchStatus status;
  final List<Listing>? listings;
  final SearchMetadata? metadata;
  final SearchError? error;

  const SearchState._({
    required this.status,
    this.listings,
    this.metadata,
    this.error,
  });

  /// Idle state - initial or no search performed yet
  factory SearchState.idle() => const SearchState._(
        status: SearchStatus.idle,
      );

      /// Loading state - search in progress
  factory SearchState.loading() => const SearchState._(
        status: SearchStatus.loading,
      );

      /// Success state - search completed with results
  factory SearchState.success({
    required List<Listing> listings,
    SearchMetadata? metadata,
  }) => SearchState._(
        status: SearchStatus.success,
        listings: listings,
        metadata: metadata,
      );

      /// Failure state - search failed with error
  factory SearchState.failure({
    required SearchError error,
  }) => SearchState._(
        status: SearchStatus.failure,
        error: error,
      );

  /// Get the current status
  SearchStatus get status => status;

  /// Check if idle
  bool get isIdle => status == SearchStatus.idle;

  /// Check if loading
  bool get isLoading => status == SearchStatus.loading;

  /// Check if success
  bool get isSuccess => status == SearchStatus.success;

  /// Check if failure
  bool get isFailure => status == SearchStatus.failure;

  /// Get the error if any
  SearchError? get errorValue => error;

  /// Get the listings if success
  List<Listing>? get listingsValue => listings;

  /// Get metadata if available
  SearchMetadata? get metadataValue => metadata;

  @override
  List<Object?> get props => [status, listings, metadata, error];

  @override
  String toString() =>
      'SearchState(status: $status, listings: ${listings?.length})';
}