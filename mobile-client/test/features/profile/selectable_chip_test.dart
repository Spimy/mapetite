import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/theme/app_colors.dart';
import 'package:mapetite/features/profile/widgets/selectable_chip.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  group('SelectableChip', () {
    testWidgets('renders label text when unselected', (tester) async {
      await tester.pumpWidget(
        wrap(SelectableChip(label: 'Nuts', isSelected: false, onTap: () {})),
      );
      expect(find.text('Nuts'), findsOneWidget);
    });

    testWidgets('renders label text when selected', (tester) async {
      await tester.pumpWidget(
        wrap(SelectableChip(label: 'Dairy', isSelected: true, onTap: () {})),
      );
      expect(find.text('Dairy'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        SelectableChip(
            label: 'Gluten', isSelected: false, onTap: () => tapped = true),
      ));
      await tester.tap(find.byType(SelectableChip));
      expect(tapped, isTrue);
    });

    testWidgets('unselected chip has neutral100 background', (tester) async {
      await tester.pumpWidget(
        wrap(SelectableChip(label: 'Eggs', isSelected: false, onTap: () {})),
      );
      final container = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(SelectableChip),
          matching: find.byType(AnimatedContainer),
        ),
      ).first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.neutral100);
    });

    testWidgets('selected chip has primary background', (tester) async {
      await tester.pumpWidget(
        wrap(SelectableChip(label: 'Soy', isSelected: true, onTap: () {})),
      );
      final container = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(SelectableChip),
          matching: find.byType(AnimatedContainer),
        ),
      ).first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('selected and unselected label colours differ', (tester) async {
      await tester.pumpWidget(
        wrap(SelectableChip(label: 'Nuts', isSelected: false, onTap: () {})),
      );
      final unselectedColor =
          tester.widget<Text>(find.text('Nuts')).style!.color;

      await tester.pumpWidget(
        wrap(SelectableChip(label: 'Nuts', isSelected: true, onTap: () {})),
      );
      final selectedColor = tester.widget<Text>(find.text('Nuts')).style!.color;

      expect(unselectedColor, isNot(equals(selectedColor)));
    });
  });
}
