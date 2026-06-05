import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/discovery/widgets/mode_choice_sheet.dart';

GoRouter _testRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showModeChoiceSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
      GoRoute(
        path: '/dine-in',
        builder: (_, _) => const Scaffold(body: Text('DineIn')),
      ),
      GoRoute(
        path: '/cook-in',
        builder: (_, _) => const Scaffold(body: Text('CookIn')),
      ),
    ],
  );
}

void main() {
  group('ModeChoiceSheet', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: _testRouter()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders "What do you want to do?" header', (tester) async {
      await openSheet(tester);
      expect(find.text('What do you want to do?'), findsOneWidget);
    });

    testWidgets('renders Dine-In card', (tester) async {
      await openSheet(tester);
      expect(find.text('Dine-In'), findsOneWidget);
    });

    testWidgets('renders Cook-In card', (tester) async {
      await openSheet(tester);
      expect(find.text('Cook-In'), findsOneWidget);
    });

    testWidgets('renders Cancel button', (tester) async {
      await openSheet(tester);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Cancel button closes sheet', (tester) async {
      await openSheet(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('What do you want to do?'), findsNothing);
    });

    testWidgets('Dine-In card navigates to /dine-in', (tester) async {
      await openSheet(tester);
      await tester.tap(find.text('Dine-In'));
      await tester.pumpAndSettle();
      expect(find.text('DineIn'), findsOneWidget);
    });

    testWidgets('Cook-In card navigates to /cook-in', (tester) async {
      await openSheet(tester);
      await tester.tap(find.text('Cook-In'));
      await tester.pumpAndSettle();
      expect(find.text('CookIn'), findsOneWidget);
    });
  });
}
