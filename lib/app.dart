import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/core/routes/app_router.dart';
import 'src/core/theme/app_theme.dart';

/// Top-level application provider setup
/// All feature modules register their providers here
final appProvider = Provider((ref) => AppState());

enum AppStatus { initial, ready, error }

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);

    return MaterialApp.router(
      title: 'Airbnb Marketplace Clone',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerDelegate: GoRouterDelegate(
        initialLocation: '/auth',
        routes: appRouter.router.options,
      ),
      routeInformationParser: appRouter.router.routeInformationParser,
      routeInformationProvider: appRouter.router.routeInformationProvider,
      fallbackRoute: (state) => '/auth/login',
    );
  }
}