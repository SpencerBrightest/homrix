import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search screen - primary guest flow
/// Features pull-to-refresh, filtering, and infinite scroll
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch search state - FSM sealed class with exhaustive .when() handling
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Listings'),
        actions: [
          // Filter chip button
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // TODO: Open filter bottom sheet
            },
          ),
        ],
      ),
      body: NotificationListener<PullNotification>(
        onPull: () async {
          // Pull-to-refresh: invalidate provider to trigger server fetch
          ref.invalidate(searchProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                _SearchBar(
                  onChanged: (query) {
                    // TODO: Trigger debounced search
                  },
                ),
                const SizedBox(height: 24),
                // Search results state handling
                searchState.when(
                  idle: () => const _SearchIdle(),
                  loading: () => const _SearchLoading(),
                  success: (listings) => _SearchResults(listings: listings),
                  failure: (error) => _SearchError(
                    onRetry: () => ref.read(searchProvider.notifier).state,
                    error: error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Search bar widget
class _SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const _SearchBar({this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Location, dates, or guests',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Empty state - no searches yet
class _SearchIdle extends StatelessWidget {
  const _SearchIdle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter search criteria above',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Filter by location, check-in/check-out dates, and guest count',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Loading state shimmer
class _SearchLoading extends StatelessWidget {
  const _SearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Loading listings...'),
      ],
    );
  }
}

/// Search results list
class _SearchResults extends ConsumerWidget {
  final SearchState listings;

  const _SearchResults({
    required this.listings,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (listings.listings.isEmpty) {
      return const _SearchNoResults();
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: listings.listings.length,
      itemBuilder: (context, index) {
        final listing = listings.listings[index];
        return _ListingCard(listing: listing);
      },
    );
  }
}

/// No results state
class _SearchNoResults extends StatelessWidget {
  const _SearchNoResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_circle_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No listings found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Error state with retry
class _SearchError extends ConsumerWidget {
  final void Function() onRetry;
  final AuthError error;

  const _SearchError({
    required this.onRetry,
    required this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load listings',
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(error.message),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}