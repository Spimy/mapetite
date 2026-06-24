import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/screens/transaction_log_screen.dart';

Widget _wrap() => const ProviderScope(
    child: MaterialApp(home: TransactionLogScreen()));

void main() {
  group('TransactionLogScreen', () {
    testWidgets('renders all mock transactions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.text('Nasi Kandar Ali'), findsOneWidget);
      expect(find.text('Jaya Grocer'), findsOneWidget);
      expect(find.text('Village Grocer'), findsOneWidget);
      expect(find.text('Kopitiam Old Town'), findsOneWidget);
      expect(find.text('99 Speedmart'), findsOneWidget);
    });

    testWidgets('search filters by merchant name', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'jaya');
      await tester.pump();

      expect(find.text('Jaya Grocer'), findsOneWidget);
      expect(find.text('Nasi Kandar Ali'), findsNothing);
    });

    testWidgets('Dining filter hides groceries transactions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('Dining'));
      await tester.pump();

      expect(find.text('Nasi Kandar Ali'), findsOneWidget);
      expect(find.text('Kopitiam Old Town'), findsOneWidget);
      expect(find.text('Jaya Grocer'), findsNothing);
    });

    testWidgets('each row is wrapped in a Slidable widget', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(Slidable), findsNWidgets(5));
    });
  });
}
