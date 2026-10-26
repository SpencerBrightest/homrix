# Notifications Architecture

## Status

Proposed integration. Firebase Cloud Messaging (FCM), APNs, Android push
configuration, and a notification service are not present in this scaffold.
Choose and configure the provider, backend sender, permissions, and platform
entitlements before implementation.

## Delivery Path

The intended push path is:

1. A trusted backend decides that a notification should be sent and constructs
   a minimal, versioned payload.
2. FCM delivers to Android through Google Play services and routes Apple-device
   delivery through APNs using configured credentials.
3. The operating system may display a notification while the app is backgrounded
   or terminated, subject to platform permission and payload rules.
4. When the app is foregrounded, a centralized notification service receives
   events and exposes typed events to the application layer.
5. The app routes the user to the relevant screen and reloads authoritative
   resource data through a repository.

Push delivery is best-effort and may be delayed, duplicated, or reordered. A
push payload is a hint, not a source of truth. Do not encode sensitive data or
authorize actions based only on its contents.

## Client Service and State

Keep platform SDK calls inside a `NotificationService` adapter. Handle
permission requests, token registration/rotation, foreground messages, opened
notifications, and token removal on sign-out. Riverpod can expose typed
foreground events and permission/registration state after it is added; widgets
must not subscribe directly to the SDK.

Payloads should include a schema version, event type, and opaque resource ID
where appropriate. Validate payloads, ignore unknown event versions safely,
and avoid logging device tokens or personal content.

## Platform Readiness

- Configure APNs credentials and iOS capabilities for the selected environment.
- Configure Android Firebase app identity and required notification channels.
- Request notification permission contextually and support denial.
- Test foreground, background, terminated, token-refresh, and notification-tap
  flows on real devices or supported platform test environments.
- Ensure notification routing works when the target resource was deleted or is
  no longer accessible.
