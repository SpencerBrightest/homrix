# Authentication and User Profiles

## Status

Supabase email/password authentication is implemented in the Flutter client.
The Supabase project, email-confirmation policy, and production Row Level
Security policies must be configured for the deployment environment.

## Responsibilities

The backend authenticates identities and authorizes protected operations. The
Flutter client stores only the minimum credential material required by the
chosen auth flow, using platform-appropriate secure storage. Do not store
passwords, expose tokens in logs, or treat a locally selected role as proof of
authorization.

## User Domain

An initial domain model may include:

| Field         | Meaning                                                      |
| ------------- | ------------------------------------------------------------ |
| `id`          | Stable server-issued user identifier                         |
| `displayName` | User-visible name                                            |
| `email`       | Optional verified contact address, subject to privacy policy |
| `activeRole`  | Selected app experience: guest or host                       |
| `roles`       | Roles granted by the server                                  |
| `createdAt`   | Server creation timestamp                                    |

This is a starting outline, not a committed database schema. Admin status must
not be granted by client-side profile toggling. The server's authorization
claims remain authoritative.

## Riverpod State

The generated `AuthStateController` is an `AsyncNotifier`: it restores sessions
and exposes sign-in, sign-up, and sign-out operations. Its UI-facing state
distinguishes loading, signed-out, and authenticated session data, while
provider errors remain recoverable. Keep the selected guest/host experience as
a separate profile preference constrained by roles granted by the server.

The controller restores a session, signs in with email/password, registers an
account, and signs out. Token values are not placed in widget state or exposed
through UI-facing models. Role changes remain a separate future operation and
must be constrained to roles granted by the server.

New accounts receive the trusted `app_metadata.role = "user"` from the
`supabase/migrations/20261026150000_set_default_auth_user_role.sql` trigger.
The sign-up request also carries `user_metadata.role = "user"` for display or
compatibility only; user metadata is editable by the client and must never be
used for authorization. Existing trusted `app_metadata.role = "admin"` values
are preserved by the migration; all other or missing role values become
`"user"`. The client reads the role from `app_metadata`.

## Token and Session Requirements

- Supabase Auth manages session persistence and access-token refresh in the
  Flutter SDK. Do not copy session tokens into ordinary app preferences or logs.
- `.env` supplies only the public Supabase project URL and
  publishable/anon key.
  These values are embedded in client builds and are not secrets.
- Never include a service-role key in the Flutter client. Enforce authorization
  with Supabase Row Level Security and use trusted server functions for
  privileged operations.
- Do not authorize from `user_metadata.role` or client UI checks. Use trusted
  app metadata or server-controlled role tables and enforce permissions in
  RLS policies.
- Handle expired credentials, offline startup, revoked sessions, and account
  deletion without showing protected cached data to a different account.
- Scope cached user data by account and clear or isolate it on sign-out.

## Acceptance Checks

- Session restoration has explicit loading, signed-out, authenticated, and
  recoverable-error behavior.
- Role selection cannot grant a server role or bypass backend authorization.
- Credentials are absent from logs, analytics, and ordinary local storage.
- Widget tests cover authentication form validation, login/signup transitions,
  and direct navigation to the protected route while unauthenticated. Add
  backend integration coverage for expired sessions and cache isolation before
  using account-scoped offline data.
