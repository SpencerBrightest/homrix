# Contributing

Homrix is currently an early Flutter scaffold. Keep changes small, reviewable,
and consistent with the target architecture in [ARCHITECTURE.md](ARCHITECTURE.md).
Do not present planned integrations as implemented functionality.

## Branching

- Do not develop directly on `main`.
- Create a focused branch from the repository's agreed integration branch, for
  example `feature/auth-foundation` or `fix/listing-cache-refresh`.
- Keep changes scoped to one coherent task and open a review before merging.
- Never commit secrets, local credentials, generated build output, or unrelated
  user changes.

## Dart and Flutter

- Follow `analysis_options.yaml`, Dart formatting, and existing naming/style
  conventions. Prefer clear, typed APIs and small cohesive widgets/classes.
- Keep widgets focused on rendering and user intent; place business rules and
  data access behind domain/repository boundaries.
- Do not perform network requests directly in widgets.
- Add tests for changed behavior, especially repository synchronization,
  failure handling, and state transitions.
- Update documentation when an architectural decision or workflow changes.

## Riverpod Policy

Once Riverpod is added, all new providers must use modern Riverpod Generator
annotations (`@riverpod` or `@Riverpod` as appropriate) and generated provider
references. Do not introduce legacy handwritten provider declarations such as
`Provider(...)`, `StateProvider(...)`, or `StateNotifierProvider(...)` for new
code. Migrate existing code only as part of a scoped change; do not perform a
blind repository-wide rewrite.

Commit generated files only when the repository's chosen Riverpod/build_runner
configuration requires them to be checked in. Keep generated output consistent
with its source annotations.

## Before Review

Run the checks relevant to the change:

```sh
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

If a command cannot run because a dependency, platform toolchain, or feature is
not configured, report that limitation in the change description. Do not claim
tests passed without running them.
