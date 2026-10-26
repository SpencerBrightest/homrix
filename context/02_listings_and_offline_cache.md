# Listings and Offline Cache

## Status

Proposed specification. No listing API, repository, Riverpod dependency, or
local database is implemented yet. The database choice (including whether to
use Isar) remains open; follow [ARCHITECTURE.md](../ARCHITECTURE.md) and record
the decision before committing storage-specific code.

## Ownership

- The repository coordinates local and remote sources.
- Local storage is the UI's source of truth for listing data.
- The remote API is the authority for canonical listing content and access.
- Riverpod providers expose repository streams and sync operations; they are
  not a substitute for durable storage.
- Widgets never call the API or database directly.

## Pull-to-Refresh Sequence

1. The screen watches a generated Riverpod provider backed by a repository
   stream; cached listings render without waiting for the network.
2. A refresh gesture invokes a repository sync command through the relevant
   controller/notifier. Prevent duplicate in-flight refreshes where practical.
3. The remote data source requests updates with the chosen pagination and
   conditional-request strategy.
4. The repository validates response versions, maps DTOs to domain/storage
   models, and persists the accepted result transactionally.
5. The local store emits its updated listing stream; Riverpod propagates the
   change to the UI.
6. On failure, keep displaying cached results and surface a retryable sync
   status. Do not replace usable cache with an empty list because a request
   failed.

## Storage Model to Decide

Before implementation, define stable listing IDs, required fields, schema
versioning/migrations, image/media handling, query indexes, deletion/tombstone
semantics, and account/region scoping. Pick a local database based on supported
queries, migration needs, platform coverage, and maintenance requirements; no
specific database is mandated here.

## Writes and Consistency

Listing edits and saved/favorite state need separate authority rules. For any
optimistic mutation, persist a pending operation or equivalent status, define
retry/backoff and idempotency behavior, and reconcile server acceptance or
rejection. Do not promise that a local edit has reached the server. Availability
and booking eligibility must always be revalidated by the backend.

## Acceptance Checks

- Existing cached listings render when offline and remain visible after sync
  failure.
- A successful refresh updates the local store and the watched UI state.
- Repeated refresh actions do not corrupt data or launch uncontrolled duplicate
  work.
- Tests cover empty cache, stale cache, pagination, malformed/failed responses,
  and schema migration once those behaviors are implemented.
