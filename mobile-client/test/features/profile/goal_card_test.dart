import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/theme/app_colors.dart';
import 'package:mapetite/features/profile/widgets/goal_card.dart';

void main() {
  // GoalCard must live inside a Row with Expanded — it uses Expanded internally.
  Widget wrap(Widget card) => MaterialApp(
        home: Scaffold(
          body: Row(children: [Expanded(child: card)]),
        ),
      );

  group('GoalCard', () {
    testWidgets('renders label text when unselected', (tester) async {
      await tester.pumpWidget(wrap(
        GoalCard(
          label: 'Lose Weight',
          icon: Icons.trending_down,
          isSelected: false,
          onTap: () {},
        ),
      ));
      expect(find.text('Lose Weight'), findsOneWidget);
    });

    testWidgets('renders label text when selected', (tester) async {
      await tester.pumpWidget(wrap(
        GoalCard(
          label: 'General Health',
          icon: Icons.favorite_outline,
          isSelected: true,
          onTap: () {},
        ),
      ));
      expect(find.text('General Health'), findsOneWidget);
    });

    testWidgets('renders the icon', (tester) async {
      await tester.pumpWidget(wrap(
        GoalCard(
          label: 'Gain Muscle',
          icon: Icons.fitness_center_outlined,
          isSelected: false,
          onTap: () {},
        ),
      ));
      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        GoalCard(
          label: 'Maintain Weight',
          icon: Icons.monitor_weight_outlined,
          isSelected: false,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(GoalCard));
      expect(tapped, isTrue);
    });

    testWidgets('selected card has primary background', (tester) async {
      await tester.pumpWidget(wrap(
        GoalCard(
          label: 'Lose Weight',
          icon: Icons.trending_down,
          isSelected: true,
          onTap: () {},
        ),
      ));
      final container = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(GoalCard),
          matching: find.byType(AnimatedContainer),
        ),
      ).first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('unselected card has white background', (tester) async {
      await tester.pumpWidget(wrap(
        GoalCard(
          label: 'Lose Weight',
          icon: Icons.trending_down,
          isSelected: false,
          onTap: () {},
        ),
      ));
      final container = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(GoalCard),
          matching: find.byType(AnimatedContainer),
        ),
      ).first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.white);
    });
  });
}
