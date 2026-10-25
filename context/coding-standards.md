# Coding Standards & Riverpod Conventions

## Dart Formatting

```bash
# Format entire project
dart format lib/ test/

# Check format (exit 1 if not formatted)
dart format --set-exit-if-changed lib/ test/

# Pre-commit hook recommended
# .gitconfig: [commit]
#   hoot = !sh -c "dart format --set-exit-if-changed lib/ test/ || exit 1"
```

## Riverpod Generator Annotations

### ✅ CORRECT Patterns

```dart
// 1. @riverpod generator - ALWAYS use build_runner
@riverpod
class SearchState extends $SearchState {
  @override
  SearchState build(ref ref) => SearchState.idle();
}

// 2. StateNotifierProvider with FSM sealed class
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(
    listingRepository: ref.read(listingRepositoryProvider),
    searchRepository: ref.read(searchRepositoryProvider),
  ),
);

// 3. Consumption via .when() - exhaustive handling
final data = ref.watch(searchProvider);
return data.when(
  idle: () => const ShimmerLoader(),
  loading: () => const CircularProgressIndicator(),
  success: (listings) => ListView.builder(
    itemCount: listings.length,
    itemBuilder: (context, index) => ListingCard(listings[index]),
  ),
  failure: (error) => ErrorRetry(onRetry: () {}),
);
```

### ❌ ANTI-PATTERNS (forbidden)

```dart
// 1. Manual Provider - NO (use @riverpod generator instead)
final searchProvider = Provider((ref) => SearchService());

// 2. setState inside Flutter widgets for state management
//    (breaks determinism, untestable)
void _onFilterChanged() {
  setState(() => _isLoading = true); // ❌
}

// 3. State mutation directly (never)
state.searchQuery = newQuery; // ❌ - State is final

// 4. Mixing Riverpod with StateMixin
//    Choose ONE pattern consistently
class OldStyle extends StatefulWidget {
  @override
  State<OldStyle> createState() => _OldStyleState();
}

class _OldStyleState extends State<OldStyle> {
  bool _isLoading = false; // ❌ private bool, not reactive
}
```

### Riverpod Provider Types Reference

| Provider Type | Annotation | Usage Pattern |
|--------------|-----------|--------------|
| `StateProvider` | `@StateProvider()` | Simple boolean/integer/enum state |
| `StateNotifierProvider` | `@StateNotifier()` | Complex FSM states with notifier |
| `FutureProvider` | `@FutureProvider()` | Single async operation result |
| `StreamProvider` | `@StreamProvider()` | Async streams (booking updates) |
| `FamilyProvider` | `@FamilyProvider()` | Parameterized streams (`bookingStatus(bookingId)`) |
| `CacheProvider` | Custom | Local cache state (Hive/Isar) |

### Sealed Class FSM Rules

| Rule | Rationale | Example |
|------|-----------|---------|
| **All UI** consumes via `.when()` | Compiler forces exhaustive handling | `state.when(idle:, loading:, success:, failure:)` |
| **Sealed classes** implement `FSM` interface | Guarantees `status`, `isIdle`, etc. | `abstract class AuthState implements FSM<AuthState>` |
| **State is `final`** - never mutate | Reactive updates only via notifier | `final state = ref.watch(provider);` |
| **No `setState()` in providers** | Impure, breaks Riverpod reactivity | Use `state = SearchState.success(...)` instead |
| **@riverpod generator** mandatory | Compile-time ref type safety | Run `build_runner` before commits |
| **Single source of truth** per feature | One provider per FSM domain | `searchProvider` only for search domain |