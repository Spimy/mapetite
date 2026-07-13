import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/auth/screens/register_screen.dart';
import 'package:mapetite/features/auth/widgets/password_strength_bar.dart';
import 'package:mapetite/shared/widgets/app_text_field.dart';

GoRouter _testRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Text('Login')),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('Home')),
      ),
    ],
  );
}

void main() {
  testWidgets('renders PasswordStrengthBar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _testRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PasswordStrengthBar), findsOneWidget);
  });

  testWidgets('Create Account button disabled without terms', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _testRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final createAccountButton = find.ancestor(
      of: find.text('Create Account'),
      matching: find.byType(ElevatedButton),
    );

    final button = tester.widget<ElevatedButton>(createAccountButton);

    expect(button.onPressed, isNull);
  });

  testWidgets(
    'shows validation errors on empty submit after accepting terms',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: _testRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final createAccountButton = find.ancestor(
        of: find.text('Create Account'),
        matching: find.byType(ElevatedButton),
      );

      final button = tester.widget<ElevatedButton>(createAccountButton);
      expect(button.onPressed, isNotNull);

      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      expect(find.text('Username is required.'), findsOneWidget);
      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
    },
  );

  testWidgets('renders all required form fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _testRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.widgetWithText(AppTextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(AppTextField, 'Email address'), findsOneWidget);
    expect(find.widgetWithText(AppTextField, 'Password'), findsOneWidget);
    expect(
      find.widgetWithText(AppTextField, 'Confirm password'),
      findsOneWidget,
    );
  });
}