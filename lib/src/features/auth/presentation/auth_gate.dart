import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth gate - first screen user sees
/// Checks authentication state and routes accordingly
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state - forces exhaustive handling via FSM
    final authState = ref.watch(authStateProvider);

    return authState.when(
      unknown: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      unauthenticated: () => const LoginScreen(),
      authenticating: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      authenticated: (user) => _buildHomeScreen(user, context),
      failure: (error) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${error.code}: ${error.message}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(authStateProvider.notifier).logout(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen(AuthUser user, BuildContext context) {
    // Role-based routing
    if (user.isAdmin) {
      return const AdminDashboardScreen();
    }
    if (user.isHost) {
      return const HostHomeScreen();
    }
    return const GuestHomeScreen();
  }
}

/// Login screen with email/password and biometric options
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isBiometric = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hotel,
                  size: 80,
                  color: Color(0xFFFF5A5F),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your Airbnb account',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'enter your email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'enter your password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _handleLogin(),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('or'),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Biometric login
                      const ListTile(
                        leading: Icon(Icons.fingerprint),
                        title: Text('Login with Fingerprint'),
                        subtitle: Text('Use biometric authentication'),
                        dense: true,
                      ),
                      const SizedBox(height: 24),
                      // Register link
                      TextButton(
                        onPressed: () {
                          // Navigate to registration
                        },
                        child: const Text('Create new account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authStateProvider.notifier)
          .login(email: _emailController.text, password: _passwordController.text);
    } catch (e) {
      // Error shown in UI via FSM state
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}