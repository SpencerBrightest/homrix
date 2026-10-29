import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homrix/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_explore_screen.g.dart';

const _rausch = Color(0xFFFF5A5F);
const _charcoal = Color(0xFF484848);
const _muted = Color(0xFF717171);

enum ExploreTab { explore, wishlists, trips, inbox, profile }

enum StayCategory { homes, rooms, beachfront, cabins, amazingViews }

class _CategoryItem {
  const _CategoryItem(this.category, this.label, this.icon);

  final StayCategory category;
  final String label;
  final IconData icon;
}

const _categories = [
  _CategoryItem(StayCategory.homes, 'Homes', Icons.home_outlined),
  _CategoryItem(StayCategory.rooms, 'Rooms', Icons.bed_outlined),
  _CategoryItem(StayCategory.beachfront, 'Beachfront', Icons.beach_access),
  _CategoryItem(StayCategory.cabins, 'Cabins', Icons.cabin_outlined),
  _CategoryItem(
    StayCategory.amazingViews,
    'Amazing views',
    Icons.landscape_outlined,
  ),
];

class _MockListing {
  const _MockListing({
    required this.id,
    required this.title,
    required this.location,
    required this.details,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.guestFavorite = false,
  });

  final String id;
  final String title;
  final String location;
  final String details;
  final String price;
  final String rating;
  final String imageUrl;
  final bool guestFavorite;
}

const _mockListings = [
  _MockListing(
    id: 'casa-verde',
    title: 'Casa Verde with a garden view',
    location: 'Mexico City, Mexico',
    details: '2 beds · May 12–17',
    price: '\$142',
    rating: '4.96',
    imageUrl: 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1200&q=85',
    guestFavorite: true,
  ),
  _MockListing(
    id: 'sunny-loft',
    title: 'Sunlit loft in the heart of town',
    location: 'Roma Norte, Mexico',
    details: '1 bed · May 18–23',
    price: '\$98',
    rating: '4.91',
    imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=85',
    guestFavorite: true,
  ),
  _MockListing(
    id: 'blue-room',
    title: 'Thoughtful room in a design home',
    location: 'Coyoacán, Mexico',
    details: '1 bed · Jun 2–7',
    price: '\$76',
    rating: '4.89',
    imageUrl: 'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1200&q=85',
  ),
  _MockListing(
    id: 'quiet-retreat',
    title: 'Quiet retreat with warm interiors',
    location: 'Condesa, Mexico',
    details: '3 beds · Jun 10–15',
    price: '\$184',
    rating: '4.98',
    imageUrl: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1200&q=85',
    guestFavorite: true,
  ),
];

/// Riverpod-managed state for explore categories, favorites, and bottom tabs.
@Riverpod(keepAlive: true)
class ExploreShellController extends _$ExploreShellController {
  @override
  ExploreShellState build() => const ExploreShellState();

  void selectTab(ExploreTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void selectCategory(StayCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleFavorite(String listingId) {
    final favorites = {...state.favoriteIds};
    if (!favorites.add(listingId)) favorites.remove(listingId);
    state = state.copyWith(favoriteIds: favorites);
  }
}

@immutable
class ExploreShellState {
  const ExploreShellState({
    this.selectedTab = ExploreTab.explore,
    this.selectedCategory = StayCategory.homes,
    this.favoriteIds = const {},
  });

  final ExploreTab selectedTab;
  final StayCategory selectedCategory;
  final Set<String> favoriteIds;

  ExploreShellState copyWith({
    ExploreTab? selectedTab,
    StayCategory? selectedCategory,
    Set<String>? favoriteIds,
  }) {
    return ExploreShellState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

/// Protected explore homepage with mock vacation-rental listings.
class HomeExploreScreen extends ConsumerWidget {
  const HomeExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreState = ref.watch(exploreShellControllerProvider);
    final authState = ref.watch(authStateControllerProvider).asData?.value;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SearchHeader(
              displayName: user?.displayName,
              onFilterTap: () => _showFilterMessage(context),
            ),
            _CategorySelector(
              selectedCategory: exploreState.selectedCategory,
              onSelected: (category) => ref
                  .read(exploreShellControllerProvider.notifier)
                  .selectCategory(category),
            ),
            Expanded(
              child: exploreState.selectedTab == ExploreTab.explore
                  ? _ExploreFeed(
                      favoriteIds: exploreState.favoriteIds,
                      onFavorite: (id) => ref
                          .read(exploreShellControllerProvider.notifier)
                          .toggleFavorite(id),
                    )
                  : _TabPlaceholder(tab: exploreState.selectedTab),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavigation(
        selectedTab: exploreState.selectedTab,
        onSelected: (tab) =>
            ref.read(exploreShellControllerProvider.notifier).selectTab(tab),
      ),
    );
  }

  void _showFilterMessage(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filters are coming soon.')));
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.displayName, required this.onFilterTap});

  final String? displayName;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Material(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Search is coming soon.')),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              children: [
                const Icon(Icons.search, size: 24, color: _charcoal),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Where to?',
                        style: TextStyle(
                          color: _charcoal,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        displayName == null
                            ? 'Anywhere · Any week · Add guests'
                            : 'Anywhere · Any week · ${displayName!}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Filters',
                  onPressed: onFilterTap,
                  icon: const Icon(Icons.tune, size: 20, color: _charcoal),
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    minimumSize: const Size(40, 40),
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

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selectedCategory,
    required this.onSelected,
  });

  final StayCategory selectedCategory;
  final ValueChanged<StayCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 26),
        itemBuilder: (context, index) {
          final item = _categories[index];
          final selected = item.category == selectedCategory;
          return InkWell(
            onTap: () => onSelected(item.category),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Icon(item.icon, size: 25, color: selected ? _rausch : _muted),
                  const SizedBox(height: 7),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? _charcoal : _muted,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 3,
                    width: selected ? 34 : 0,
                    decoration: const BoxDecoration(
                      color: _rausch,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExploreFeed extends StatelessWidget {
  const _ExploreFeed({required this.favoriteIds, required this.onFavorite});

  final Set<String> favoriteIds;
  final ValueChanged<String> onFavorite;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: _mockListings.length,
      itemBuilder: (context, index) {
        final listing = _mockListings[index];
        return _ListingCard(
          listing: listing,
          isFavorite: favoriteIds.contains(listing.id),
          onFavorite: () => onFavorite(listing.id),
        );
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.isFavorite,
    required this.onFavorite,
  });

  final _MockListing listing;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    listing.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const ColoredBox(
                        color: Color(0xFFF0EFED),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _rausch,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(
                          color: Color(0xFFF0EFED),
                          child: Center(
                            child: Icon(
                              Icons.home_outlined,
                              color: _muted,
                              size: 42,
                            ),
                          ),
                        ),
                  ),
                  if (listing.guestFavorite)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Text(
                            'Guest favorite',
                            style: TextStyle(
                              color: _charcoal,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      tooltip: isFavorite
                          ? 'Remove from wishlist'
                          : 'Add to wishlist',
                      onPressed: onFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? _rausch : Colors.white,
                        size: 27,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 13,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (dotIndex) => Container(
                          width: dotIndex == 0 ? 7 : 5,
                          height: dotIndex == 0 ? 7 : 5,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: dotIndex == 0
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: Text(
                  listing.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _charcoal,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.star, size: 16, color: _charcoal),
              const SizedBox(width: 4),
              Text(
                listing.rating,
                style: const TextStyle(color: _charcoal, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            listing.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 14),
          ),
          Text(
            listing.details,
            style: const TextStyle(color: _muted, fontSize: 14),
          ),
          const SizedBox(height: 7),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: _charcoal, fontSize: 14),
              children: [
                TextSpan(
                  text: listing.price,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' night'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedTab,
    required this.onSelected,
  });

  final ExploreTab selectedTab;
  final ValueChanged<ExploreTab> onSelected;

  static const _items = [
    (ExploreTab.explore, 'Explore', Icons.search, Icons.search),
    (ExploreTab.wishlists, 'Wishlists', Icons.favorite_border, Icons.favorite),
    (ExploreTab.trips, 'Trips', Icons.airline_stops, Icons.airline_stops),
    (ExploreTab.inbox, 'Inbox', Icons.chat_bubble_outline, Icons.chat_bubble),
    (
      ExploreTab.profile,
      'Profile',
      Icons.account_circle_outlined,
      Icons.account_circle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (final item in _items)
                Expanded(
                  child: _BottomNavItem(
                    label: item.$2,
                    icon: selectedTab == item.$1 ? item.$4 : item.$3,
                    selected: selectedTab == item.$1,
                    onTap: () => onSelected(item.$1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _rausch : _muted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.tab});

  final ExploreTab tab;

  @override
  Widget build(BuildContext context) {
    final copy = switch (tab) {
      ExploreTab.explore => ('Explore stays', Icons.search),
      ExploreTab.wishlists => ('Your wishlists', Icons.favorite_border),
      ExploreTab.trips => ('Your trips', Icons.airline_stops),
      ExploreTab.inbox => ('Your messages', Icons.chat_bubble_outline),
      ExploreTab.profile => ('Your profile', Icons.account_circle_outlined),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(copy.$2, size: 48, color: _rausch),
          const SizedBox(height: 12),
          Text(
            copy.$1,
            style: const TextStyle(
              color: _charcoal,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This section is coming soon.',
            style: TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }
}

/// Compatibility name retained for existing authentication route tests.
class BlankHomeScreen extends HomeExploreScreen {
  const BlankHomeScreen({super.key});
}
