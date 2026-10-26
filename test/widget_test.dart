// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homrix/app/router/app_router.dart';
import 'package:homrix/main.dart';

void main() {
  testWidgets('login validates fields before opening the blank home screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HomrixApp());
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

    await tester.pumpWidget(const HomrixApp());
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
    await tester.pumpWidget(const HomrixApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(appRouterProvider).go('/home');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(find.text('Find your next stay'), findsNothing);
  });
}
