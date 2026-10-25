# Offline-First Synchronization & Interaction Logic

## Repository Pattern - Source of Truth

All Flutter UI reads **solely** from the local cache engine. Network is purely for sync.

### Local DataSource (Hive/Isar Example)

```dart
class LocalDataSource {
  final HiveInterface hive;
  
  LocalDataSource(this.hive);

  // Guest: cached search results
  Future<SearchState> getSearchCache(String query) async {
    final box = hive.box<SearchBox>('search_cache');
    final cached = box.get(query);
    return cached != null ? SearchState.fromJson(cached.json) : SearchState.idle();
  }

  void saveSearchCache(String query, SearchState state) async {
    final box = hive.box<SearchBox>('search_cache');
    await box.put(query, SearchBox(
      query: query,
      json: state.toJson(),
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    )..save());
  }

  // Host: cached listings
  Future<List<Listing>> getCachedListings() async {
    final box = hive.box<ListingBox>('listings');
    return box.values.toList().map((e) => e.toDomain()).toList();
  }

  void saveCachedListing(Listing listing) async {
    final box = hive.box<ListingBox>('listings');
    await box.put(
      listing.id,
      ListingBox.fromDomain(listing)
    )..save();
  }
}
```

### Remote DataSource (Supabase/Firebase Example)

```dart
class RemoteDataSource {
  final SupabaseClient _client;
  
  RemoteDataSource(this._client);

  Future<Either<SearchError, SearchState>> fetchSearchFromServer({
    required String query,
    required DateRange dateRange,
    required int guestCount,
  }) async {
    try {
      final response = await _client
          .from('searches')
          .select()
          .eq('query', query)
          .gte('check_in', dateRange.start)
          .lte('check_out', dateRange.end)
          .eq('guest_count', guestCount)
          .maybeSingle();

      return Right(SearchState.fromJson(response));
    } on PostgresException catch (e) {
      return Left(SearchError(
        code: e.code,
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }
}
```

### Repository Pattern - Unified Interface

```dart
class ListingRepository {
  final LocalDataSource _local;
  final RemoteDataSource _remote;
  final SyncQueue _syncQueue;

  ListingRepository({
    required LocalDataSource local,
    required RemoteDataSource remote,
    required SyncQueue syncQueue,
  })  : _local = local,
        _remote = remote,
        _syncQueue = syncQueue;

  /// GET - Read ONLY from local cache (UI mandate)
  Future<SearchState> getSearch(String query) async {
    return await _local.getSearchCache(query);
  }

  /// PULL-TO-REFRESH FLOW
  Future<void> refreshSearch(String query) async {
    // 1. Kick off async provider routine
    // 2. Fetch from server through remote data source
    final result = await _remote.fetchSearchFromServer(query: query);

    // 3. Write directly to local cache
    result.fold(
      (failure) => _syncQueue.enqueue(
        Operation(
          type: OperationType.refresh,
          query: query,
          error: failure,
        ),
      ),
      (success) {
        await _local.saveSearchCache(query, success);
        // 4. Reactive pump: local cache → Riverpod → UI thread
        // NO explicit screen freeze states - reactive framework handles it
      },
    );
  }

  /// OPTIMISTIC UI - Local modifications at 0ms latency
  Future<void> toggleFavorite(String listingId) async {
    // 1. Process locally immediately
    await _local.toggleFavoriteCache(listingId);
    
    // 2. Optimistic UI update - reflect immediately
    // Riverpod state updates via local cache notification
    
    // 3. Queue structural network synchronization
    _syncQueue.enqueue(
      Operation(
        type: OperationType.favoriteToggle,
        listingId: listingId,
        persist: true,
      ),
    );
  }

  /// SYNC QUEUE - Background persistence
  void startSyncEngine() {
    _syncQueue.process().listen(
      (operation) async {
        final result = await _remote.persist(operation);
        if (result.isLeft()) {
          // Conflict resolution: merge local → remote, or ask user
          await _syncQueue.retry(operation);
        }
      },
      onError: (error) {
        // Persist to retry-later queue
        _syncQueue.persistForLater(error);
      },
    );
  }
}
```

### Pull-to-Refresh Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    PULL-TO-REFRESH FLOW                     │
├─────────────────────────────────────────────────────────────┤
│  1. User pulls down on search results screen                │
│  │                                                       │
│  ▼                                                       │
│  2. ref.invalidate(searchProvider) OR manual execution    │
│  │                       ▲                             │
│  │                       │                             │
│  ▼                       │                             │
│  3. Repository.refreshSearch(query) ←───────────────────┘
│  │                       │                             │
│  │                       │                             │
│  ▼                       │                             │
│  4. Server fetch → async provider routine               │
│  │                       │                             │
│  ▼                       │                             │
│  5. Local cache write (Hive/Isar)                     │
│  │                       │                             │
│  ▼                       │                             │
│  6. Reactive Riverpod pump → UI updates (no freeze)     │
│  │                       │                             │
│  ▼                       │                             │
│  7. New data emitted → UI rebuild with fresh data       │
│  └─────────────────────────────────────────────────────────┘
```

### Optimistic UI Strategy

| Action | Local Latency | Network Sync | Failure Handling |
|--------|--------------|--------------|-----------------|
| Like/unlike property | 0ms | Background queue | Revert + show toast |
| Add/remove from wishlist | 0ms | Background queue | Revert + show toast |
| Draft listing save | 0ms | Immediate write | Keep local, queue retry |
| Calendar toggle (open/blocked) | 0ms | Background sync | Merge conflict resolution |
| Price update | 0ms | Background queue | Revert + show error |

### Conflict Resolution Strategy

```
WHEN offline changes clash with server updates:

1. Last-Write-Wins (timestamp-based)
   └─ If: local modified_at > server modified_at → keep local
   └─ If: server modified_at > local modified_at → reconcile

2. Field-level merge
   └─ Non-conflicting fields: keep both
   ├─ Example: User changed "name" offline → server changed "price"
   └─ Both updates merge since different fields

3. User prompt (last resort)
   └─ If: same field conflict + both have valid values
   └─ Show: "Host updated price to $200 while you had $180 offline"
   └─ Options: Keep mine, Keep host's, Manual override
```

### Sync Queue Guarantees

- ✅ **At-least-once delivery**: Every queued operation eventually reaches server or retry-later queue
- ✅ **Order preservation**: Operations processed in FIFO order per resource
- ✅ **App restart persistence**: Sync queue survives app restarts (disk-backed)
- ✅ **Backpressure**: If server rate-limits, queue pauses and resumes automatically
- ✅ **Idempotency**: Same operation repeated twice has same effect (unique operation IDs)