import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/widgets/toast_helpers.dart';

Widget _scaffold(void Function(BuildContext) onContext) {
  return MaterialApp(
    home: Builder(builder: (ctx) {
      onContext(ctx);
      return const Scaffold(body: SizedBox.shrink());
    }),
  );
}

void main() {
  group('showErrorSnackbar', () {
    testWidgets('renders the message and a Retry button when onRetry is given',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_scaffold((c) => ctx = c));

      showErrorSnackbar(
        ctx,
        'Could not save transaction. Please try again.',
        onRetry: () {},
      );
      await tester.pump();

      expect(find.text('Could not save transaction. Please try again.'),
          findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls onRetry when Retry is tapped', (tester) async {
      late BuildContext ctx;
      var retried = false;
      await tester.pumpWidget(_scaffold((c) => ctx = c));

      showErrorSnackbar(ctx, 'Failed.', onRetry: () => retried = true);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('omits the Retry button when onRetry is not given',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_scaffold((c) => ctx = c));

      showErrorSnackbar(ctx, 'Failed.');
      await tester.pump();

      expect(find.text('Failed.'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });
}
