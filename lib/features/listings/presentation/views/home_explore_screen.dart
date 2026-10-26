import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homrix/features/auth/presentation/providers/auth_state_provider.dart';

/// Protected homepage shell for the listings and exploration experience.
class HomeExploreScreen extends ConsumerWidget {
  const HomeExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateControllerProvider).asData?.value;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('homrix'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () =>
                ref.read(authStateControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.explore_outlined,
              color: Color(0xFFFF5A5F),
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Find your next stay',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            if (user != null) ...[
              const SizedBox(height: 8),
              Text('Welcome, ${user.displayName}'),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compatibility name retained for the existing widget test contract.
class BlankHomeScreen extends HomeExploreScreen {
  const BlankHomeScreen({super.key});
}
