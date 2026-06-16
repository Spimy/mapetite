import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches without crash', (WidgetTester tester) async {
    // Splash screen calls SharedPreferences — provide mock initial values.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MapetiteApp()),
    );
    expect(find.text('Eat Smart. Live Well.'), findsOneWidget);
    // Advance past the splash screen timer and allow async navigation to settle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
