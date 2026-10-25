import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/features/auth/presentation/authgate.dart';
import 'src/features/search/presentation/search_screen.dart';
import 'src/features/listings/presentation/host_listing_screen.dart';
import 'src/features/bookings/presentation/booking_flow_screen.dart';
import 'src/features/notifications/presentation/notification_screen.dart';
import 'src/features/admin/presentation/admin_dashboard_screen.dart';

/// Application-wide router configuration
/// Defines all navigation paths and guards
final goRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    /// Auth gates - first screen user sees
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthGate(),
    ),

    /// Search & Discovery
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),

    /// Host Listing Management
    GoRoute(
      path: '/host/listings',
      name: 'host-listings',
      builder: (context, state) => const HostListingScreen(),
    ),

    /// Booking Flow
    GoRoute(
      path: '/bookings/:bookingId',
      name: 'booking-flow',
      builder: (context, state) => BookingFlowScreen(
        bookingId: state.pathParameters['bookingId'] ?? '',
      ),
    ),

    /// Notifications
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationScreen(),
    ),

    /// Admin Dashboard
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
  refreshListenable: appProvider,
);