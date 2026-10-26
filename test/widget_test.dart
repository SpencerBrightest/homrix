// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homrix/app/router/app_router.dart';
import 'package:homrix/features/auth/domain/entities/user_profile.dart';
import 'package:homrix/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:homrix/main.dart';

void main() {
  testWidgets('login validates fields before opening the blank home screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(HomrixApp(authRepository: _TestAuthRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('email_field')),
      'guest@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byType(BlankHomeScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('sign-up validates required fields and matching passwords', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(HomrixApp(authRepository: _TestAuthRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toggle_auth_mode')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('signup_submit')));
    await tester.tap(find.byKey(const Key('signup_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your first name'), findsOneWidget);
    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.byType(BlankHomeScreen), findsNothing);
  });

  testWidgets('unauthenticated navigation to home is redirected to login', (
    tester,
  ) async {
    await tester.pumpWidget(HomrixApp(authRepository: _TestAuthRepository()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(appRouterProvider).go('/home');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(find.text('Find your next stay'), findsNothing);
  });

  testWidgets('restores an existing session and opens the home route', (
    tester,
  ) async {
    await tester.pumpWidget(
      HomrixApp(authRepository: _TestAuthRepository()..signedIn = true),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BlankHomeScreen), findsOneWidget);
    expect(find.text('Welcome, Test Guest'), findsOneWidget);
  });

  testWidgets('Supabase auth events update the Riverpod route state', (
    tester,
  ) async {
    final repository = _TestAuthRepository();
    await tester.pumpWidget(HomrixApp(authRepository: repository));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_submit')), findsOneWidget);

    repository.emitSession(_TestAuthRepository.user);
    await tester.pumpAndSettle();
    expect(find.byType(BlankHomeScreen), findsOneWidget);

    repository.emitSession(null);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });

  testWidgets('sign-up submits validated account data', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _TestAuthRepository();
    await tester.pumpWidget(HomrixApp(authRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toggle_auth_mode')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Ada');
    await tester.enterText(find.byType(TextFormField).at(1), 'Lovelace');
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'ada@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('confirm_password_field')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('signup_submit')));
    await tester.tap(find.byKey(const Key('signup_submit')));
    await tester.pumpAndSettle();

    expect(repository.createdEmail, 'ada@example.com');
    expect(repository.createdDisplayName, 'Ada Lovelace');
    expect(find.byType(BlankHomeScreen), findsOneWidget);
  });

  testWidgets('sign-up waits for email confirmation when required', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _TestAuthRepository()..requiresEmailConfirmation = true;
    await tester.pumpWidget(HomrixApp(authRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toggle_auth_mode')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Ada');
    await tester.enterText(find.byType(TextFormField).at(1), 'Lovelace');
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'ada@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('confirm_password_field')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('signup_submit')));
    await tester.tap(find.byKey(const Key('signup_submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('Check your email to confirm your account.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(find.byType(BlankHomeScreen), findsNothing);
  });
}

class _TestAuthRepository implements AbstractAuthRepository {
  final _authChanges = StreamController<UserProfile?>.broadcast(sync: true);
  bool signedIn = false;
  bool requiresEmailConfirmation = false;
  String? createdEmail;
  String? createdDisplayName;

  static const user = UserProfile(
    id: 'test-user',
    displayName: 'Test Guest',
    email: 'test@example.com',
  );

  @override
  Stream<UserProfile?> get authStateChanges => _authChanges.stream;

  void emitSession(UserProfile? user) {
    signedIn = user != null;
    _authChanges.add(user);
  }

  @override
  Future<UserProfile?> getCurrentUser() async => signedIn ? user : null;

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    signedIn = true;
    return user;
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    createdEmail = email;
    createdDisplayName = displayName;
    signedIn = !requiresEmailConfirmation;
    return requiresEmailConfirmation;
  }

  @override
  Future<void> signOut() async {
    signedIn = false;
  }
}
