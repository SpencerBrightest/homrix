# Architecture

## Status

This is the intended architecture, not a description of every current runtime
integration. Riverpod now composes the app shell and auth gate. Authentication
is a clearly labeled demo-only in-memory session; it is not production identity
verification or durable session persistence.

## Product Boundary

Homrix is planned as a marketplace with guest, host, and platform-admin roles.
The Flutter client owns presentation and local interaction. A trusted backend
owns identity verification, authorization, booking decisions, payment-related
operations, push delivery, and AI provider credentials.

## Layers and Ownership

Use feature-oriented modules with explicit domain, data, and presentation
responsibilities. Adapt folder names to the existing project as it grows:

```text
lib/
  app/                 # app composition, routing, theme
  core/                # shared primitives, errors, platform adapters
  features/
    <feature>/
      data/            # API and local data sources, DTOs, repository impls
      domain/          # entities, repository contracts, use cases as needed
      presentation/    # screens, widgets, generated Riverpod providers
```

- Widgets render state and send user intent to application/domain operations.
- Repositories coordinate remote and local data sources and define the feature's
  consistency behavior.
- The local store is the client-side source of truth for cached marketplace
  data. UI must not issue HTTP requests or access a remote API directly.
- Remote data sources encapsulate transport and DTO conversion. Do not leak
  transport models into widgets or domain contracts.
- Riverpod provides dependency injection, UI state, and reactive observation of
  repository/cache state. Riverpod's in-memory provider state is not a durable
  database; persistent offline data belongs in a selected local-storage layer.

## State and Server Data

Use Riverpod Generator annotations (`@riverpod`) for providers and follow
generated provider lifetimes. Riverpod is the chosen
client state-management and reactive server-data coordination layer; do not add
TanStack Query, Zustand, or a competing state/cache framework without an
architecture decision.

Expose repository operations and local cache streams through providers. A
screen watches those providers; it does not fetch remote data itself. Pull to
refresh requests repository synchronization and then observes the local store
as it changes. Provider invalidation may trigger recomputation, but it is not
by itself a persistence or synchronization strategy.

Represent multi-step user flows with explicit state transitions. Use Dart
sealed classes when a flow has mutually exclusive states that benefit from
exhaustive handling; do not force every simple value or UI interaction into an
FSM.

## Offline-First Data Flow

For a read/sync operation, the target flow is:

1. The UI subscribes to a provider backed by the repository's local data stream.
2. The repository reads cached data immediately when available.
3. A synchronization request asks the remote data source for updates.
4. The repository validates and maps the response, then commits it to local
   storage in a transaction where supported.
5. The local stream emits the committed state; Riverpod updates the UI.
6. On network or server failure, retain usable cached data and expose a
   recoverable sync error separately from the cached content.

The database, conflict policy, retry/backoff policy, deletion semantics, and
background-sync mechanism are not selected yet. Do not assume Isar, SQLite,
Drift, or another store until the project records that decision. Optimistic
writes require an explicit pending/synced/failed model and reconciliation
behavior; never claim immediate cloud persistence from a local write.

## Security and Integrations

- The server is authoritative for authorization, availability, booking
  acceptance, and any financial operation.
- Keep secrets and AI provider credentials on trusted servers. The client may
  call authenticated application endpoints, never a provider using a bundled
  secret.
- Treat push payloads as untrusted hints; fetch authoritative resource state
  through the repository.
- Validate and version API contracts. Avoid logging credentials, tokens, or
  sensitive personal data.

## Decisions Required Before Production

Record choices and rationale for the local database, backend/API contract,
authentication and token storage, booking/payment authority, conflict and
retry semantics, push provider, AI endpoints, and observability/privacy policy.
Update this document when implementation decisions become concrete.
