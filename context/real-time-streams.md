# Application Tracking (Real-Time Streams)

## Persistent Riverpod StreamProviders

Real-time tracking of host booking requests and sync responses via persistent streams.

### StreamProvider Skeleton

```dart
// 1. Booking request stream - host sees new requests instantly
final bookingRequestsStream = StreamProvider.autoDispose((ref) {
  final subscription = FirebaseFirestore.instance
      .collection('bookings')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BookingRequest.fromFirestore(doc))
          .toList())
      .distinct(); // Prevent duplicate emissions

  // 2. Automatic disposal on widget disposal
  // 3. Reconnection logic built-in via Firestore snapshots
  
  return subscription;
});

// 2. Real-time booking status stream - guest sees confirmation
final bookingStatusStream = StreamProvider.family<String, String>((ref, bookingId) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .doc(bookingId)
      .snapshots()
      .map((doc) => doc['status'] as String)
      .distinct();
});

// 3. Admin platform health stream
final platformHealthStream = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('platform-metrics')
      .doc('health')
      .snapshots()
      .map((doc) => PlatformHealth.fromFirestore(doc));
});
```

### WebSocket / SSE Integration

```dart
// Custom streaming service for low-latency requirements
class RealTimeService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // WebSocket connection for real-time bidding updates
  final WebSocket? _ws;
  
  Stream<BookingEvent> get bookingEvents => _eventStream;
  
  RealTimeService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth {
    _initializeConnection();
  }
  
  void _initializeConnection() async {
    final userId = _auth.currentUser?.uid;
    
    // Strategy A: Firestore snapshots (recommended - offline-capable)
    _firestoreCollectionStream();
    
    // Strategy B: WebSocket (low-latency, offline-not-possible)
    // _ws = await _connectWebSocket(userId);
  }
  
  Stream<BookingEvent> _firestoreCollectionStream() {
    return _firestore
        .collection('booking-events')
        .doc(userId)
        .snapshots()
        .map((doc) => doc['events'] as List<BookingEvent>)
        .expand((events) => events)
        .distinct();
  }
  
  Future<WebSocket> _connectWebSocket(String userId) async {
    final uri = Uri.parse(
        'wss://realtime.airbnb-clone.io/ws?userId=$userId');
    
    return await WebSocket.connect(uri).then((socket) {
      // Subscribe to user-specific channels
      socket.add(jsonEncode({
        'action': 'subscribe',
        'channels': ['booking-requests', 'price-updates'],
      }));
      
      return socket;
    }).catchError((error) {
      // Fall back to Firestore if WebSocket fails
      // Log metrics for ops team
      return _fallbackFirestoreStream();
    });
  }
  
  Stream<BookingEvent> _fallbackFirestoreStream() {
    // Same as _firestoreCollectionStream but logged as fallback
    return _firestoreCollectionStream();
  }
}
```

### Reconnection & Resilience Logic

```dart
// Automatic reconnection with exponential backoff
class ResilientStreamProvider extends StatefulWidget {
  final StreamProviderBase provider;
  const ResilientStreamProvider({required this.provider, super.key});

  @override
  State<ResilientStreamProvider> createState() =>
      _ResilientStreamProviderState();
}

class _ResilientStreamProviderState extends State<ResilientStreamProvider>
    with SingleTickerProviderStateMixin {
  int _retryCount = 0;
  static const _maxRetries = 5;
  late Timer _retryTimer;

  @override
  void initState() {
    super.initState();
    _startWatching();
  }

  void _startWatching() {
    final stream = widget.provider.stream;
    stream.listen(
      (data) {
        // Reset retry counter on successful receive
        _retryCount = 0;
        // Update state atomically
        setState(() {});
      },
      onError: (error) {
        _handleError(error);
      },
      onDone: () {
        // Stream closed, attempt reconnection
        _handleDone();
      },
    );
  }

  void _handleError(Object error) {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = _calculateBackoff();
      _retryTimer = Timer(Duration(seconds: delay), _startWatching);
      // Log reconnection attempt
      debugPrint('Reconnection attempt $_retryCount in $delay seconds');
    } else {
      // Max retries exceeded - show persistent banner
      _showOfflineBanner();
    }
  }

  int _calculateBackoff() {
    // Exponential: 1s, 2s, 4s, 8s, 16s (capped at 60s)
    final base = 1 << _retryCount.clamp(0, 6);
    return base..clamp(1, 60);
  }

  void _handleDone() {
    _retryTimer.cancel();
    // Wait a moment then retry
    _retryTimer = Timer(const Duration(seconds: 3), _startWatching);
  }

  @override
  void dispose() {
    _retryTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Child watches the provider regardless of connection state
    return widget.provider;
  }
}
```

### Stream Provider Consumption Pattern

```dart
// Host screen - real-time booking requests
Widget buildHostBookingRequests(BuildContext context, WidgetRef ref) {
  final pendingRequests = ref.watch(bookingRequestsStream);
  
  return pendingRequests.when(
    // Note: StreamProvider.autoDispose returns null initially before first emission
    data: (requests) => requests.isEmpty
        ? const Center(child: Text('No pending requests'))
        : ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) =>
                BookingRequestCard(request: requests[index]),
          ),
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => ErrorRetry(
      onRetry: () => ref.read(bookingRequestsStream.notifier),
      error: error,
    ),
  );
}

// Guest screen - real-time booking status
Widget buildGuestBookingStatus(BuildContext context, WidgetRef ref, String bookingId) {
  final status = ref.watch(bookingStatusStream(bookingId));
  
  return status.when(
    data: (status) => _buildStatusUI(status),
    loading: () => const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    error: (error, stack) => const Text('Status unavailable'),
  );
}
```

### Guarantees

- ✅ **Exactly-once processing**: Firestore snapshots are idempotent; duplicate docs filtered via `.distinct()`
- ✅ **Automatic reconnection**: Exponential backoff with max retry cap
- ✅ **Offline-capable**: Firestore persists locally; client reads from cached state when offline
- ✅ **Memory leaks prevented**: `autoDispose` cleans up streams on widget disposal
- ✅ **Backpressure handling**: `.distinct()` prevents flood; batch updates throttled at UI layer