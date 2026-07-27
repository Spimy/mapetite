import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mapetite/features/settings/screens/about_screen.dart';

GoRouter _testRouter() => GoRouter(
      initialLocation: '/about',
      routes: [
        GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
        GoRoute(
          path: '/about/terms',
          builder: (_, _) => const Scaffold(body: Text('Terms')),
        ),
        GoRoute(
          path: '/about/privacy',
          builder: (_, _) => const Scaffold(body: Text('Privacy')),
        ),
        GoRoute(
          path: '/about/licences',
          builder: (_, _) => const Scaffold(body: Text('Licences')),
        ),
      ],
    );

Widget _wrap() => MaterialApp.router(routerConfig: _testRouter());

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Mapetite',
      packageName: 'com.mapetite.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('renders the tagline below the wordmark', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Your smart companion for a healthier, more connected urban lifestyle.'),
      findsOneWidget,
    );
  });

  testWidgets('renders the real package version and build number',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
  });

  testWidgets('mission copy mentions the SDGs', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.textContaining('SDG'), findsWidgets);
  });

  testWidgets('renders all three SDG commitment cards', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Good Health & Well-being'), findsOneWidget);
    expect(find.text('Sustainable Cities'), findsOneWidget);
    expect(find.text('Responsible Consumption'), findsOneWidget);
  });

  testWidgets('tapping Terms of Service navigates to /about/terms',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Terms of Service'),
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );

    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.text('Terms'), findsOneWidget);
  });

  testWidgets('renders the contact email', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('hello@mapetite.app'), findsOneWidget);
  });
}
