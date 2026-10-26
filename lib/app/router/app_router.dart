import 'package:go_router/go_router.dart';
import 'package:homrix/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homrix/features/auth/presentation/views/login_screen.dart';
import 'package:homrix/features/auth/presentation/views/splash_screen.dart';
import 'package:homrix/features/listings/presentation/views/home_explore_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Creates the application router and refreshes redirects when auth changes.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const BlankHomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      final authState = ref.read(authStateControllerProvider);
      final currentAuth = authState.asData?.value;

      if (authState.isLoading ||
          currentAuth is AuthInitial ||
          currentAuth is AuthLoading) {
        return location == '/splash' ? null : '/splash';
      }

      if (currentAuth is Authenticated) {
        return location == '/login' || location == '/splash' ? '/home' : null;
      }

      // Authentication errors fail closed just like a missing session.
      return location == '/login' ? null : '/login';
    },
  );

  ref.listen(authStateControllerProvider, (previous, next) {
    router.refresh();
  });
  ref.onDispose(router.dispose);
  return router;
}
