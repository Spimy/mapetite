import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/theme/app_colors.dart';
import 'package:mapetite/shared/widgets/app_empty_state.dart';
import 'package:mapetite/shared/widgets/custom_button.dart';

void main() {
  testWidgets(
      'defaults to tertiary icon background, primary icon colour, and primary button variant',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppEmptyState(
          icon: Icons.error_outline,
          title: 'Title',
          description: 'Description',
          ctaLabel: 'Retry',
          onCta: () {},
        ),
      ),
    ));

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.tertiary);

    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    expect(icon.color, AppColors.primary);

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.variant, AppButtonVariant.primary);
  });

  testWidgets('applies custom iconBackgroundColor, iconColor, and buttonVariant',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppEmptyState(
          icon: Icons.wifi_off,
          iconBackgroundColor: AppColors.neutral100,
          iconColor: AppColors.neutral600,
          title: 'Title',
          description: 'Description',
          ctaLabel: 'Retry',
          buttonVariant: AppButtonVariant.outlined,
          onCta: () {},
        ),
      ),
    ));

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.neutral100);

    final icon = tester.widget<Icon>(find.byIcon(Icons.wifi_off));
    expect(icon.color, AppColors.neutral600);

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.variant, AppButtonVariant.outlined);
  });
}
