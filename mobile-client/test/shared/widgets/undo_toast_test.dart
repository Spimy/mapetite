import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/widgets/undo_toast.dart';

Widget _scaffold(void Function(BuildContext) onContext) {
  return MaterialApp(
    home: Builder(builder: (ctx) {
      onContext(ctx);
      return const Scaffold(body: SizedBox.shrink());
    }),
  );
}

void main() {
  group('showUndoToast', () {
    testWidgets('renders message and Undo button', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_scaffold((c) => ctx = c));

      showUndoToast(
        context: ctx,
        message: 'Item deleted',
        onUndo: () {},
        duration: const Duration(seconds: 10),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Item deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('calls onUndo when Undo button tapped', (tester) async {
      late BuildContext ctx;
      var called = false;
      await tester.pumpWidget(_scaffold((c) => ctx = c));

      showUndoToast(
        context: ctx,
        message: 'Item deleted',
        onUndo: () => called = true,
        duration: const Duration(seconds: 10),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.text('Item deleted'), findsNothing);
    });

    testWidgets('auto-dismisses after duration', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_scaffold((c) => ctx = c));

      // Use 300ms — longer than the 250ms entrance so the entrance finishes
      // before the timer fires and the exit begins.
      showUndoToast(
        context: ctx,
        message: 'Gone soon',
        onUndo: () {},
        duration: const Duration(milliseconds: 300),
      );
      await tester.pump(); // frame 0 — overlay inserted
      await tester.pump(const Duration(milliseconds: 260)); // entrance completes
      expect(find.text('Gone soon'), findsOneWidget); // toast fully visible

      // Advance just past the 300ms threshold to fire the timer.
      await tester.pump(const Duration(milliseconds: 50)); // t=310ms — exit starts
      // pumpAndSettle runs the remaining 250ms exit animation frames to completion
      // and processes the entry.remove() rebuild.
      await tester.pumpAndSettle();

      expect(find.text('Gone soon'), findsNothing);
    });

    testWidgets('cancel callback dismisses toast early', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_scaffold((c) => ctx = c));

      final cancel = showUndoToast(
        context: ctx,
        message: 'Cancellable',
        onUndo: () {},
        duration: const Duration(seconds: 10),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Cancellable'), findsOneWidget);

      cancel();
      await tester.pumpAndSettle();

      expect(find.text('Cancellable'), findsNothing);
    });
  });
}
