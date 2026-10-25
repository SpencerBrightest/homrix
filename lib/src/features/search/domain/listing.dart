/// Domain model for a property listing
///
/// Represents a single listing in the Airbnb marketplace
class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final int guestCount;
  final bool isFavorite;
  final DateTime lastUpdated;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.guestCount,
    this.isFavorite = false,
    required this.lastUpdated,
    required this.createdAt,
  });

  /// Copy with for immutability
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? location,
    int? bedrooms,
    int? bathrooms,
    int? guestCount,
    bool? isFavorite,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) => Listing(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    price: price ?? this.price,
    imageUrl: imageUrl ?? this.imageUrl,
    location: location ?? this.location,
    bedrooms: bedrooms ?? this.bedrooms,
    bathrooms: bathrooms ?? this.bathrooms,
    guestCount: guestCount ?? this.guestCount,
    isFavorite: isFavorite ?? this.isFavorite,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    createdAt: createdAt ?? this.createdAt,
  );

  /// Convert from Map (from API response)
  factory Listing.fromMap(Map<String, dynamic> map) => Listing(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    price: (map['price'] as num).toDouble(),
    imageUrl: map['imageUrl'],
    location: map['location'],
    bedrooms: map['bedrooms'],
    bathrooms: map['bathrooms'],
    guestCount: map['guestCount'],
    isFavorite: map['isFavorite'] ?? false,
    lastUpdated: DateTime.parse(map['lastUpdated']),
    createdAt: DateTime.parse(map['createdAt']),
  );

  /// Convert to Map (for API requests)
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'location': location,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'guestCount': guestCount,
    'isFavorite': isFavorite,
    'lastUpdated': lastUpdated.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => 'Listing(id: $id, title: $title, price: \$${price.toStringAsFixed(2)})';
}