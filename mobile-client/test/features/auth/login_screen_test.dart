import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/auth/screens/login_screen.dart';

GoRouter _testRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LoginScreen()),
        GoRoute(
          path: '/forgot-password',
          builder: (_, _) => const Scaffold(body: Text('ForgotPassword')),
        ),
        GoRoute(
          path: '/register',
          builder: (_, _) => const Scaffold(body: Text('Register')),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

void main() {
  testWidgets('shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('shows error for invalid email format', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'notanemail',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('renders all key elements', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
