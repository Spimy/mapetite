import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/widgets/pricing_badge.dart';

Widget _wrap(Widget child) =>
    ProviderScope(child: MaterialApp(home: Scaffold(body: child)));

void main() {
  group('PricingBadge', () {
    testWidgets('budget bracket renders label text', (tester) async {
      await tester.pumpWidget(
          _wrap(const PricingBadge(bracket: PricingBracket.budget)));
      expect(find.text('RM 5–10'), findsOneWidget);
    });

    testWidgets('mid bracket renders label text', (tester) async {
      await tester.pumpWidget(
          _wrap(const PricingBadge(bracket: PricingBracket.mid)));
      expect(find.text('RM 10–20'), findsOneWidget);
    });

    testWidgets('premium bracket renders label text', (tester) async {
      await tester.pumpWidget(
          _wrap(const PricingBadge(bracket: PricingBracket.premium)));
      expect(find.text('RM 20+'), findsOneWidget);
    });

    testWidgets('custom label overrides default bracket label', (tester) async {
      await tester.pumpWidget(_wrap(const PricingBadge(
        bracket: PricingBracket.budget,
        customLabel: 'Budget Friendly',
      )));
      expect(find.text('Budget Friendly'), findsOneWidget);
      expect(find.text('RM 5–10'), findsNothing);
    });
  });
}
