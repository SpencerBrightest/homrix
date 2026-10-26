import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homrix/app/router/app_router.dart';
import 'package:homrix/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:homrix/features/auth/presentation/providers/auth_state_provider.dart';

/// Provides Riverpod's application scope and composes the root widget.
class HomrixApp extends StatelessWidget {
  const HomrixApp({super.key, this.authRepository});

  /// Optional injection point for tests and alternate authentication adapters.
  final AbstractAuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        if (authRepository != null)
          authRepositoryProvider.overrideWithValue(authRepository!),
      ],
      child: const _HomrixRouterApp(),
    );
  }
}

class _HomrixRouterApp extends ConsumerWidget {
  const _HomrixRouterApp();

  static const _rausch = Color(0xFFFF5A5F);
  static const _charcoal = Color(0xFF484848);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Homrix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _rausch,
          primary: _rausch,
          secondary: const Color(0xFF00A699),
          surface: Colors.white,
          onSurface: _charcoal,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
