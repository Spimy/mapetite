import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/theme/app_colors.dart';
import 'package:mapetite/features/profile/widgets/step_progress_bar.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      )));

  group('StepProgressBar', () {
    testWidgets('renders without error for 4 steps at step 0', (tester) async {
      await tester.pumpWidget(
        wrap(const StepProgressBar(totalSteps: 4, currentStep: 0)),
      );
      expect(find.byType(StepProgressBar), findsOneWidget);
    });

    testWidgets('renders without error for 4 steps at step 2', (tester) async {
      await tester.pumpWidget(
        wrap(const StepProgressBar(totalSteps: 4, currentStep: 2)),
      );
      expect(find.byType(StepProgressBar), findsOneWidget);
    });

    testWidgets('renders correct number of segments', (tester) async {
      await tester.pumpWidget(
        wrap(const StepProgressBar(totalSteps: 4, currentStep: 1)),
      );
      // 4 AnimatedContainers (the segments)
      final segments = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(StepProgressBar),
          matching: find.byType(AnimatedContainer),
        ),
      ).toList();
      expect(segments.length, 4);
    });

    testWidgets('completed segments use primary colour', (tester) async {
      await tester.pumpWidget(
        wrap(const StepProgressBar(totalSteps: 4, currentStep: 2)),
      );
      final segments = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(StepProgressBar),
          matching: find.byType(AnimatedContainer),
        ),
      ).toList();

      // First two segments should be primary-coloured
      final firstDecoration = segments[0].decoration as BoxDecoration;
      final thirdDecoration = segments[2].decoration as BoxDecoration;
      expect(firstDecoration.color, AppColors.primary);
      expect(thirdDecoration.color, AppColors.border);
    });

    testWidgets('all segments use border colour at step 0', (tester) async {
      await tester.pumpWidget(
        wrap(const StepProgressBar(totalSteps: 4, currentStep: 0)),
      );
      final segments = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(StepProgressBar),
          matching: find.byType(AnimatedContainer),
        ),
      ).toList();
      for (final segment in segments) {
        final decoration = segment.decoration as BoxDecoration;
        expect(decoration.color, AppColors.border);
      }
    });
  });
}
