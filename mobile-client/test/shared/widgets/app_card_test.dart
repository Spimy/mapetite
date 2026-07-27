import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/constants/app_spacing.dart';
import 'package:mapetite/core/theme/app_colors.dart';
import 'package:mapetite/shared/widgets/app_card.dart';

void main() {
  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppCard(child: Text('Hello'))),
    ));

    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('applies white background, border, and radiusLg corners',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppCard(child: Text('Hello'))),
    ));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.color, AppColors.white);
    expect(decoration.border, Border.all(color: AppColors.border));
    expect(decoration.borderRadius, BorderRadius.circular(AppSpacing.radiusLg));
  });

  testWidgets('defaults to AppSpacing.lg padding', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppCard(child: Text('Hello'))),
    ));

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.padding, const EdgeInsets.all(AppSpacing.lg));
  });
}
