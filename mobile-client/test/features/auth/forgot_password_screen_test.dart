import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/auth/screens/forgot_password_screen.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

class _MockUrlLauncherPlatform extends UrlLauncherPlatform {
  _MockUrlLauncherPlatform(this._result);

  bool _result;
  String? lastLaunchedUrl;

  void setResult(bool result) => _result = result;

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
  testWidgets('renders heading, explanation, and a single Reset Password button', (tester) async {
    UrlLauncherPlatform.instance = _MockUrlLauncherPlatform(true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('tapping Reset Password opens the web reset page', (tester) async {
    final mock = _MockUrlLauncherPlatform(true);
    UrlLauncherPlatform.instance = mock;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();

    expect(mock.lastLaunchedUrl, contains('/reset-password/'));
    expect(find.text('Reset your password'), findsOneWidget);
  });

  testWidgets('shows an inline error when the reset page fails to launch, and allows retry', (tester) async {
    final mock = _MockUrlLauncherPlatform(false);
    UrlLauncherPlatform.instance = mock;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _testRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not open the reset page. Please try again.'),
      findsOneWidget,
    );

    mock.setResult(true);
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not open the reset page. Please try again.'),
      findsNothing,
    );
    expect(mock.lastLaunchedUrl, contains('/reset-password/'));
  });
}
