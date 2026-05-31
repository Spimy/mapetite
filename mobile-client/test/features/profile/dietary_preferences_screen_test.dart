import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/profile/screens/dietary_preferences_screen.dart';

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/profile/dietary',
      routes: [
        GoRoute(
          path: '/profile/dietary',
          builder: (_, _) => const DietaryPreferencesScreen(),
        ),
        GoRoute(
          path: '/profile/setup',
          builder: (_, _) => const Scaffold(body: Text('Setup')),
        ),
        GoRoute(
          path: '/profile/budget-setup',
          builder: (_, _) => const Scaffold(body: Text('Budget Setup')),
        ),
      ],
    );

Widget buildApp() => ProviderScope(
      child: MaterialApp.router(routerConfig: _buildRouter()),
    );

void main() {
  group('DietaryPreferencesScreen', () {
    testWidgets('renders heading "What do you eat?"', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('What do you eat?'), findsOneWidget);
    });

    testWidgets('renders three dietary toggle rows', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Halal'), findsWidgets);
      expect(find.text('Vegetarian'), findsWidgets);
      expect(find.text('Vegan'), findsWidgets);
    });

    testWidgets('renders all six allergen chips', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      for (final allergen in ['Nuts', 'Dairy', 'Gluten', 'Shellfish', 'Eggs', 'Soy']) {
        expect(find.text(allergen), findsOneWidget,
            reason: '$allergen chip should be present');
      }
    });

    testWidgets('renders all eight cuisine chips', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      for (final cuisine in [
        'Malaysian', 'Chinese', 'Indian', 'Japanese',
        'Western', 'Thai', 'Korean', 'Middle Eastern',
      ]) {
        expect(find.text(cuisine), findsOneWidget,
            reason: '$cuisine chip should be present');
      }
    });

    testWidgets('allergen chip can be tapped without crashing', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nuts'));
      await tester.pump();
      // Second tap deselects — no crash
      await tester.tap(find.text('Nuts'));
      await tester.pump();
      expect(find.text('Nuts'), findsOneWidget);
    });

    testWidgets('renders Halal toggle switch', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('renders calorie slider', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
