import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/shared/widgets/app_drawer.dart';

GoRouter _testRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          drawer: AppDrawer(displayName: 'Aisha', savedThisMonth: 47.50),
          body: Text('Home'),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const Scaffold(body: Text('Profile Edit')),
      ),
      GoRoute(
        path: '/restaurants',
        builder: (_, _) => const Scaffold(body: Text('Restaurants')),
      ),
      GoRoute(
        path: '/groceries',
        builder: (_, _) => const Scaffold(body: Text('Groceries')),
      ),
      GoRoute(
        path: '/cook-in',
        builder: (_, _) => const Scaffold(body: Text('Cook-In')),
      ),
      GoRoute(
        path: '/list',
        builder: (_, _) => const Scaffold(body: Text('My List')),
      ),
      GoRoute(
        path: '/list/route',
        builder: (_, _) => const Scaffold(body: Text('Route Map')),
      ),
      GoRoute(
        path: '/budget/analytics',
        builder: (_, _) => const Scaffold(body: Text('Analytics')),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const Scaffold(body: Text('Settings')),
      ),
    ],
  );
}

void main() {
  group('AppDrawer', () {
    Future<void> openDrawer(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: _testRouter()),
      );
      await tester.pumpAndSettle();
      final scaffoldState =
          tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
    }

    testWidgets('renders display name in header', (tester) async {
      await openDrawer(tester);
      expect(find.text('Aisha'), findsOneWidget);
    });

    testWidgets('renders "Account & Preferences" subtitle', (tester) async {
      await openDrawer(tester);
      expect(find.text('Account & Preferences'), findsOneWidget);
    });

    testWidgets('renders savings pill text', (tester) async {
      await openDrawer(tester);
      expect(find.textContaining('Saved This Month'), findsOneWidget);
    });

    testWidgets('renders all 6 nav items', (tester) async {
      await openDrawer(tester);
      expect(find.text('Restaurants'), findsOneWidget);
      expect(find.text('Grocery Stores'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('My List'), findsOneWidget);
      expect(find.text('Route Map'), findsOneWidget);
      expect(find.text('Budget Analytics'), findsOneWidget);
    });

    testWidgets('renders Settings footer item', (tester) async {
      await openDrawer(tester);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping Restaurants navigates to restaurants screen',
        (tester) async {
      await openDrawer(tester);
      await tester.tap(find.text('Restaurants'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
      expect(find.text('Restaurants'), findsOneWidget);
    });

    testWidgets('tapping header navigates to profile edit', (tester) async {
      await openDrawer(tester);
      await tester.tap(find.text('Account & Preferences'));
      await tester.pumpAndSettle();
      expect(find.text('Profile Edit'), findsOneWidget);
    });
  });
}
