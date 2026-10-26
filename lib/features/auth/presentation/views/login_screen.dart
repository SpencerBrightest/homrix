import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homrix/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _LoginMode { login, signUp }

/// Email/password sign-in and account registration boundary.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  _LoginMode _mode = _LoginMode.login;

  bool get _isSignUp => _mode == _LoginMode.signUp;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter your $label' : null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _required(value, 'email address');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final requiredError = _required(value, 'password');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) return 'Use at least 8 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final controller = ref.read(authStateControllerProvider.notifier);
      if (_isSignUp) {
        final requiresEmailConfirmation = await controller.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          displayName:
              '${_firstNameController.text.trim()} '
              '${_lastNameController.text.trim()}',
        );
        if (requiresEmailConfirmation && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check your email to confirm your account.'),
            ),
          );
          _setMode(_LoginMode.login);
        }
      } else {
        await controller.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to complete authentication. Check your connection and '
            'Supabase configuration.',
          ),
        ),
      );
    }
  }

  void _setMode(_LoginMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
    });
  }

  Widget _nameField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      validator: (value) => _required(value, label.toLowerCase()),
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _passwordField({bool confirm = false}) {
    final controller = confirm
        ? _confirmPasswordController
        : _passwordController;
    return TextFormField(
      key: Key(confirm ? 'confirm_password_field' : 'password_field'),
      controller: controller,
      obscureText: true,
      validator: confirm
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm your password';
              }
              return value == _passwordController.text
                  ? null
                  : 'Passwords do not match';
            }
          : _validatePassword,
      decoration: InputDecoration(
        labelText: confirm ? 'Confirm password' : 'Password',
      ),
    );
  }

  Widget _buildForm() {
    final authState = ref.watch(authStateControllerProvider).asData?.value;
    final isLoading = authState is AuthLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isSignUp ? 'Create your account' : 'Welcome back',
            style: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSignUp
                ? 'Join Homrix to find a place that feels like yours.'
                : 'Log in to continue planning your next stay.',
            style: const TextStyle(color: Color(0xFF717171), height: 1.45),
          ),
          const SizedBox(height: 24),
          if (_isSignUp) ...[
            Row(
              children: [
                Expanded(child: _nameField('First name', _firstNameController)),
                const SizedBox(width: 12),
                Expanded(child: _nameField('Last name', _lastNameController)),
              ],
            ),
            const SizedBox(height: 14),
          ],
          TextFormField(
            key: const Key('email_field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: const InputDecoration(labelText: 'Email address'),
          ),
          const SizedBox(height: 14),
          _passwordField(),
          if (_isSignUp) ...[
            const SizedBox(height: 14),
            _passwordField(confirm: true),
            const SizedBox(height: 20),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password recovery is not connected in this demo.',
                    ),
                  ),
                ),
                child: const Text('Forgot password?'),
              ),
            ),
          SizedBox(
            height: 52,
            child: FilledButton(
              key: Key(_isSignUp ? 'signup_submit' : 'login_submit'),
              onPressed: isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isLoading
                    ? 'Please wait…'
                    : _isSignUp
                    ? 'Create account'
                    : 'Log in',
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _isSignUp
                ? 'A confirmation email may be required before you can sign in.'
                : 'Your account is authenticated securely with Supabase.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF717171),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeSwitch() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : 'New to Homrix?',
          style: const TextStyle(color: Color(0xFF717171)),
        ),
        TextButton(
          key: const Key('toggle_auth_mode'),
          onPressed: () =>
              _setMode(_isSignUp ? _LoginMode.login : _LoginMode.signUp),
          child: Text(_isSignUp ? 'Log in' : 'Sign up'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final form = Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildForm(), _modeSwitch()],
            );
            if (constraints.maxWidth >= 800) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: form,
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.home_work_outlined,
                        color: Color(0xFFFF5A5F),
                        size: 30,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'homrix',
                        style: TextStyle(
                          color: Color(0xFFFF5A5F),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      form,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
