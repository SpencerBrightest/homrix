import 'package:hive_flutter/hive_flutter.dart';
import '../error/failures.dart';

/// Local data source implementation using Hive for offline-first caching
///
/// All UI reads go through this source. Network writes go through Repository pattern.
abstract class HiveLocalDataSource {
  /// Get a box instance by name
  Box<T> _box<T(String key, T value>()) => Hive.box<T>('');

  /// Cached search results
  Future<SearchState> getSearchCache(String query) async {
    try {
      final box = Hive.box<SearchBox>('search_cache');
      final cached = box.get(query);
      if (cached != null) {
        return SearchState.fromJson(cached.json);
      }
      return SearchState.idle();
    } catch (e) {
      return SearchState.idle();
    }
  }

  /// Save search results to local cache
  Future<void> saveSearchCache(String query, SearchState state) async {
    try {
      final box = Hive.box<SearchBox>('search_cache');
      await box.put(query, SearchBox(
        query: query,
        json: state.toJson(),
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      )..save());
    } catch (e) {
      throw CacheFailure();
    }
  }

  /// Cached listings
  Future<List<Listing>> getCachedListings() async {
    try {
      final box = Hive.box<ListingBox>('listings');
      final items = box.values.toList();
      return items.map((e) => e.toDomain()).toList();
    } catch (e) {
      throw CacheFailure();
    }
  }

  /// Save cached listing
  Future<void> saveCachedListing(Listing listing) async {
    try {
      final box = Hive.box<ListingBox>('listings');
      await box.put(
        listing.id,
        ListingBox.fromDomain(listing)
      )..save();
    } catch (e) {
      throw CacheFailure();
    }
  }

  /// Toggle favorite in local cache
  Future<void> toggleFavoriteCache(String listingId) async {
    try {
      final box = Hive.box<FavoriteBox>('favorites');
      await box.put(
        listingId,
        FavoriteBox(
          listingId: listingId,
          isFavorite: !box.get(listingId, defaultValue: false).isFavorite,
        )..save();
      );
    } catch (e) {
      throw CacheFailure();
    }
  }

  /// Get favorite status from local cache
  Future<bool> getFavoriteCache(String listingId) async {
    try {
      final box = Hive.box<FavoriteBox>('favorites');
      return box.get(listingId, defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  /// User session persistence
  Future<void> saveSessionCache(String key, Map<String, dynamic> data) async {
    try {
      final box = Hive.box('session');
      await box.put(key, data);
    } catch (e) {
      throw CacheFailure();
    }
  }

  /// Get session data from local cache
  Future<Map<String, dynamic>?> getSessionCache(String key) async {
    try {
      final box = Hive.box('session');
      return box.get(key);
    } catch (e) {
      return null;
    }
  }

  /// Clear all local cache (on logout)
  Future<void> clearAllCache() async {
    try {
      await Hive.box('search_cache').clear();
      await Hive.box('listings').clear();
      await Hive.box('favorites').clear();
      await Hive.box('session').clear();
    } catch (e) {
      throw CacheFailure();
    }
  }
}

/// Hive data model for search cache
class SearchBox {
  final String query;
  final Map<String, dynamic> json;
  final int lastUpdated;

  SearchBox({
    required this.query,
    required this.json,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'query': query,
    'json': json,
    'lastUpdated': lastUpdated,
  };

  factory SearchBox.fromMap(Map<String, dynamic> map) => SearchBox(
    query: map['query'],
    json: map['json'],
    lastUpdated: map['lastUpdated'],
  );
}

/// Hive data model for listings cache
class ListingBox {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final bool isFavorite;
  final DateTime lastUpdated;

  ListingBox({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
    required this.lastUpdated,
  });

  factory ListingBox.fromDomain(Listing listing) => ListingBox(
    id: listing.id,
    title: listing.title,
    description: listing.description,
    price: listing.price,
    imageUrl: listing.imageUrl,
    isFavorite: listing.isFavorite,
    lastUpdated: listing.lastUpdated,
  );

  Listing toDomain() => Listing(
    id: id,
    title: title,
    description: description,
    price: price,
    imageUrl: imageUrl,
    isFavorite: isFavorite,
    lastUpdated: lastUpdated,
  );
}

/// Hive data model for favorites cache
class FavoriteBox {
  final String listingId;
  final bool isFavorite;
  final int lastUpdated;

  FavoriteBox({
    required this.listingId,
    required this.isFavorite,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'listingId': listingId,
    'isFavorite': isFavorite,
    'lastUpdated': lastUpdated,
  };

  factory FavoriteBox.fromJson(Map<String, dynamic> map) => FavoriteBox(
    listingId: map['listingId'],
    isFavorite: map['isFavorite'],
    lastUpdated: map['lastUpdated'],
  );
}