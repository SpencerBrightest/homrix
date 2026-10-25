/// Search error model
class SearchError implements Exception {
  final String code;
  final String message;

  const SearchError({
    required this.code,
    required this.message,
  });

  /// Common search error types
  static const noResults = SearchError(
    code: 'no_results',
    message: 'No listings match your search criteria',
  );

  static const invalidDates = SearchError(
    code: 'invalid_dates',
    message: 'Check-out date must be after check-in date',
  );

  static const serverError = SearchError(
    code: 'server_error',
    message: 'Search service unavailable. Please try again.',
  );

  @override
  String toString() => 'SearchError(code: $code, message: $message)';
}

/// Search metadata for pagination
class SearchMetadata {
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  const SearchMetadata({
    required this.page,
    required this.pageSize,
    required this.total,
    this.hasMore = false,
  });

  /// Check if there are more pages available
  bool get canPaginate => (page * pageSize) < total;

  /// Get the next page number
  int get nextPage => page + 1;
}