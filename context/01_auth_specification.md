# Authentication and User Profiles

## Status

Proposed specification. Authentication is not currently implemented. Select
the identity provider, backend contract, and secure-storage package before
writing production code.

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

After Riverpod Generator is installed, model the session with a generated
`AsyncNotifier` provider (for example, an annotated `SessionController`). Its
async state should distinguish loading, signed-out, and authenticated session
data, while errors remain recoverable. Keep the selected guest/host experience
as a separate profile preference constrained by roles granted by the server.

Expected operations include restoring a session, signing in, signing out,
refreshing credentials through the chosen SDK/backend, and changing the active
role when permitted. Avoid placing token values in widget state or exposing
them through UI-facing models.

## Token and Session Requirements

- Choose OAuth/OIDC or a backend-issued session strategy before implementation;
  JWT is a token format, not an authentication workflow by itself.
- Define access-token lifetime, refresh/revocation behavior, and sign-out
  semantics with the backend.
- Use secure platform storage for refresh credentials if the selected flow
  requires persistence. Do not assume ordinary preferences are secure storage.
- Handle expired credentials, offline startup, revoked sessions, and account
  deletion without showing protected cached data to a different account.
- Scope cached user data by account and clear or isolate it on sign-out.

## Acceptance Checks

- Session restoration has explicit loading, signed-out, authenticated, and
  recoverable-error behavior.
- Role selection cannot grant a server role or bypass backend authorization.
- Credentials are absent from logs, analytics, and ordinary local storage.
- Tests cover sign-in/out transitions, expired-session behavior, and cache
  isolation between accounts.
