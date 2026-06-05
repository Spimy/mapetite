import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/widgets/dietary_chip.dart';

Widget _wrap(Widget child) =>
    ProviderScope(child: MaterialApp(home: Scaffold(body: child)));

void main() {
  group('DietaryChip named constructors', () {
    testWidgets('DietaryChip.halal() renders Halal label', (tester) async {
      await tester.pumpWidget(_wrap(const DietaryChip.halal()));
      expect(find.text('Halal'), findsOneWidget);
    });

    testWidgets('DietaryChip.vegan() renders Vegan label', (tester) async {
      await tester.pumpWidget(_wrap(const DietaryChip.vegan()));
      expect(find.text('Vegan'), findsOneWidget);
    });

    testWidgets('DietaryChip.vegetarian() renders Vegetarian label',
        (tester) async {
      await tester.pumpWidget(_wrap(const DietaryChip.vegetarian()));
      expect(find.text('Vegetarian'), findsOneWidget);
    });

    testWidgets('DietaryChip.allergen() renders custom label', (tester) async {
      await tester.pumpWidget(_wrap(const DietaryChip.allergen('Nuts')));
      expect(find.text('Nuts'), findsOneWidget);
    });

    testWidgets('DietaryChip.restriction() renders custom label',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const DietaryChip.restriction('Gluten-Free')));
      expect(find.text('Gluten-Free'), findsOneWidget);
    });
  });
}
