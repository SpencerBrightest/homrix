# Notification Engine

## FCM as Routing Bridge

Firebase Cloud Messaging (FCM) partitions **Local Timers** from **Remote Push Alerts**, routing through native daemons to correct platforms.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    FIREBASE CONSOLE                           │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Campaign Management                                    │ │
│  │  - Target: guests/hosts/admin                           │ │
│  │  - Payload: booking alerts, marketing, system          │ │
│  │  - Schedule: immediate, scheduled, recurring            │ │
│  └─────────────────────────────────────────────────────────┘ │
│           ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  │
│           │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
│           │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
│    ┌─────────────┴─────────────┴─────────────┴─────────────┴┐ │
│    │              FCM SERVER LAYER                              │ │
│    │  - Topic subscriptions (guests, hosts, all)              │ │
│    │  - Device token management                               │ │
│    │  - Priority routing (normal vs high)                     │ │
│    │  - Multicast for broadcast messages                      │ │
│    └──────────────────────────────────────────────────────────┘ │
│                   ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲ │
│                   │  │  │  │  │  │  │  │  │  │  │  │  │  │ │
│  ┌──────────────┴───────────────────────┴─────────────────┴────┐│
│  │              NATIVE DAEMON ROUTING BRIDGE                    ││
│  │                                                              ││
│  │  ┌─────────────────┐  ┌────────────────────────────────┐ ││
│  │  │  iOS (APNs)     │  │  Android (Play Services)       │ ││
│  │  │  - Apple Push   │  │  - Google Play Services        │ ││
│  │  │   notification  │  │   - GCM/FCM reception          │ ││
│  │  │   daemon        │  │   - Background execution       │ ││
│  │  │   - iOS 10+     │  │   - Doze mode aware            │ ││
│  │  │   - APNs SSL    │  │   - Android 4.0+             │ ││
│  │  │   - Sandbox/Prod│  │   - Notification Channels      │ ││
│  │  └─────────────────┘  └────────────────────────────────┘ ││
│  └─────────────────────────────────────────────────────────────┘┘
└─────────────────────────────────────────────────────────────────┘
```

### Local Timers vs Remote Push Alerts

| Aspect | Local Timers | Remote Push Alerts |
|--------|-------------|-------------------|
| **Trigger** | Dart `Timer`, `Isolate`, `WorkManager` | Firebase FCM → Native daemon |
| **Persistence** | App memory only | FCM server persists across restarts |
| **Connectivity** | Requires app foreground/midground | Works even with app closed/terminated |
| **Battery impact** | Low (Dart-isolate) | Optimized by OS native daemons |
| **Use cases** | "Remind me in 2 hours", "Countdown to check-in" | "New booking request", "Payment received" |
| **Implementation** | `riverpod:timer` provider, `workout:background_fetch` | `fcm listeners`, `onMessage`, `onBackgroundMessage` |

### FCM Message Payload Structure

```dart
// Client-side message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Log delivery for admin analytics
  await NotificationLogService.logDelivery(
    title: message.notification?.title,
    body: message.notification?.body,
    topic: message.data['topic'],
    recipientRole: message.data['recipientRole'],
  );
  
  // Handle based on data fields
  switch (message.data['type']) {
    case 'new_booking':
      // Host: navigate to booking requests
      _router.navigate('/host/booking-requests');
      break;
    case 'booking_confirmed':
      // Guest: navigate to booking confirmation
      _router.navigate('/guest/booking-confirmation');
      break;
    case 'payment_received':
      // Host: update earnings
      _router.navigate('/host/earnings');
      break;
    case 'review_received':
      // Both: notification center
      _router.navigate('/notifications');
      break;
    default:
      // General notification
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(message.notification?.body ?? '')),
      );
  }
}

// Foreground message listener
void startForegroundListen() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Instant UI update without FCM routing
    _showInAppNotification(message);
    
    // Also emit Riverpod state for cross-screen awareness
    ref.read(notificationsProvider.notifier).onNewMessage(message);
  });
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}
```

### Device Token Lifecycle

```
1. App start → request permission → get FCM token
2. Token → store in local cache (Hive box: 'fcm_tokens')
3. Token → upload to remote API: POST /api/user-tokens {token, platform, os_version}
4. Admin dashboard: view registered tokens, deactivate stale
5. Token rotation: on app uninstall, remove; on re-install, regenerate
6. Topic subscriptions: /topics/guests, /topics/hosts, /topics/admin
```

### Notification Priority Routing

| Priority | Use Case | iOS APNs | Android Play Services |
|----------|----------|----------|----------------------|
| **Normal** | Booking updates, marketing, weekly summaries | Delivered when app in foreground/background | Delivered when device awake; may be deferred |
| **High** | Instant booking requests, payment alerts, security | Immediate, always deliver | Immediate, wake device, bypass Doze |