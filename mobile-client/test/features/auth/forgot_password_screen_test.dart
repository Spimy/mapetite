import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/auth/screens/forgot_password_screen.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

class _MockUrlLauncherPlatform extends UrlLauncherPlatform {
  _MockUrlLauncherPlatform(this._result);

  final bool _result;
  String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    return _result;
  }
}

GoRouter _testRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ForgotPasswordScreen()),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Login')),
        ),
      ],
    );

void main() {
  testWidgets('renders input state initially', (tester) async {
    UrlLauncherPlatform.instance = _MockUrlLauncherPlatform(true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email address'), findsOneWidget);
  });

  testWidgets('shows validation error on empty email submit', (tester) async {
    UrlLauncherPlatform.instance = _MockUrlLauncherPlatform(true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
  });

  testWidgets('shows success state after the reset page launches', (tester) async {
    final mock = _MockUrlLauncherPlatform(true);
    UrlLauncherPlatform.instance = mock;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'test@example.com',
    );
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.text('Back to Sign In'), findsOneWidget);
    expect(mock.lastLaunchedUrl, contains('/reset-password/'));
  });

  testWidgets('shows an inline error when the reset page fails to launch', (tester) async {
    UrlLauncherPlatform.instance = _MockUrlLauncherPlatform(false);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'test@example.com',
    );
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not open the reset page. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Reset your password'), findsOneWidget);
  });

  testWidgets('resend button shows countdown after success', (tester) async {
    UrlLauncherPlatform.instance = _MockUrlLauncherPlatform(true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'test@example.com',
    );
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Resend in'), findsOneWidget);
  });
}
