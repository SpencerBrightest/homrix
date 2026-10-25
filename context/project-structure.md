# Project Structure

## Feature-First Flutter Layout

```
lib/
├── src/
│   ├── core/                    # Shared cross-cutting concerns
│   │   ├── theme/               # AppTheme, extensions, constants
│   │   ├── routes/              # GoRouter configuration
│   │   ├── error/               # Failures, exceptions, error handling
│   │   ├── network/             # Dio/HTTP client, interceptors
│   │   ├── storage/             # Hive/Isar boxes, local data sources
│   │   └── utils/               # String, date, number extensions
│   │
│   ├── shared/                  # Widgets and logic used across features
│   │   ├── widgets/             # Reusable UI: buttons, cards, shimmer
│   │   ├── components/          # Composite components: header, filters, etc.
│   │   └── state/               # Shared notifiers, FSM base classes
│   │
│   └── features/                # Feature-based grouping (recommended)
│       ├── auth/                # Authentication & onboarding
│       │   ├── data/            # Repository, data sources, models
│       │   ├── domain/          # Use cases, entities, FSM states
│       │   ├── presentation/    # UI screens, Riverpod providers
│       │   └── utils/           # Auth-specific helpers
│       │
│       ├── search/              # Search & discovery
│       │   ├── data/            # Search repository, remote/local datasources
│       │   ├── domain/          # Search FSM, listing entities, filters
│       │   ├── presentation/    # SearchScreen, filter chips, results grid
│       │   └── utils/           # Search query builders
│       │
│       ├── listings/            # Host listing management
│       │   ├── data/            # Listing repository, photo upload
│       │   ├── domain/          # Listing FSM, calendar entities
│       │   ├── presentation/    # HostListingScreen, calendar widget
│       │   └── utils/           # Listing calculators
│       │
│       ├── bookings/            # Transaction flow
│       │   ├── data/            # Booking repository, payment gateway
│       │   ├── domain/          # Booking FSM, payment entities
│       │   ├── presentation/    # BookingFlowScreen, status tracker
│       │   └── utils/           # Booking calculators
│       │
│       ├── profile/             # User/profile management
│       │   ├── data/            # User repository
│       │   ├── domain/          # User entity, preferences
│       │   ├── presentation/    # ProfileScreen, settings
│       │   └── utils/           # Profile updaters
│       │
│       ├── notifications/       # FCM & in-app notifications
│       │   ├── data/            # Notification repository
│       │   ├── domain/          # Notification FSM, preference entity
│       │   └── presentation/    # NotificationSettingsScreen
│       │
│       └── admin/               # Platform admin tools
│           ├── data/            # Admin repository
│           ├── domain/          # Admin FSM, policy entities
│           └── presentation/    # AdminDashboard, validation tools
│
├── main.dart                    # App entry point, router config
└── app.dart                     # Top-level provider setup
```

## Key Directory Conventions

| Directory | Purpose | Rationale |
|-----------|---------|-----------|
| `lib/src/core/` | Cross-cutting concerns shared by ALL features | Avoid duplication, single source of truth for themes, routes, error handling |
| `lib/src/features/` | Feature-based grouping | New developers locate code by business domain, not technical layer |
| `lib/src/features/\[feature\]/data/` | Data layer only | Repositories, data sources, models, local cache configs |
| `lib/src/features/\[feature\]/domain/` | Business logic only | Use cases, entities, FSM states, domain exceptions - NO Flutter imports |
| `lib/src/features/\[feature\]/presentation/` | UI layer only | Screens, Riverpod providers, UI logic - NO business logic |
| `lib/src/features/\[feature\]/utils/` | Feature-specific helpers | Query builders, formatters, calculators used only by that feature |

## File Naming Conventions

| File Type | Naming Pattern | Example |
|-----------|---------------|---------|
| Provider/Notifier | `\[camelCase]Provider.dart` | `searchStateProvider.dart` |
| Sealed class FSM | `\[PascalCase]State.dart` | `AuthState.dart` |
| Repository | `\[PascalCase]Repository.dart` | `listingRepository.dart` |
| Data Source | `\[PascalCase]DataSource.dart` | `hiveLocalDataSource.dart` |
| Model/Entity | `\[PascalCase].dart` | `Listing.model.dart` |
| Use Case | `\[Verb]\[Noun]UseCase.dart` | `fetchSearchUseCase.dart` |
| UI Screen | `\[PascalCase]Screen.dart` | `SearchScreen.dart` |
| Widget | `\[pascalCase]Widget.dart` | `ShimmerCardWidget.dart` |
| Constants | `\[PascalCase].dart` | `AppConstants.dart` |
| Extensions | `\[PascalCase]Extensions.dart` | `StringExtensions.dart` |

## Asset Organization

```
assets/
├── images/                      # Placeholder images, icons
├── fonts/                       # Custom fonts (Google Fonts installed via pubspec)
├── animations/                  # Lottie/JSON animations
└── ui/                          # Static UI assets used across features
```

## Example Feature Structure - Listings

```
listings/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── listing_local_data_source.dart
│   │   └── remote/
│   │       └── api_listing_data_source.dart
│   ├── repositories/
│   │   └── listing_repository_impl.dart
│   └── models/
│       └── listing_model.dart
│
├── domain/
│   ├── entities/
│   │   └── listing_entity.dart
│   ├── fsm/
│   │   └── listing_state.dart
│   └── usecases/
│       ├── fetch_listings_use_case.dart
│       └── toggle_favorite_use_case.dart
│
└── presentation/
    ├── providers/
    │   └── listing_notifier.dart
    ├── screens/
    │   ├── host_listing_screen.dart
    │   └── guest_listing_screen.dart
    └── widgets/
        ├── listing_card.dart
        └── calendar_picker.dart
```

## Why Feature-First (vs Feature-Sliced)?

| Feature-Sliced (layers) | Feature-First (domains) | Your Choice |
|------------------------|------------------------|-------------|
| `auth/model.dart`, `auth/view.dart`, `auth/store.dart` | `auth/use_cases/`, `auth/screens/`, `auth/utils/` | **Feature-First** recommended - matches your spec's "multi-sided marketplace" domain logic |
| All auth code in one folder | Each feature isolated by business concern | Easier onboarding, clearer boundaries, faster builds |
| Rename `auth/` → `users/` affects all layers | Rename `listings/` → `listings/` only affects listings | Feature-first = safer refactoring |