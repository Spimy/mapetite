import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/app.dart';

void main() {
  testWidgets('App launches without crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MapetiteApp()),
    );
    expect(find.text('Mapetite'), findsOneWidget);
    // Advance past the splash screen timer to prevent pending timer assertion
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
