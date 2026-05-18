import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/app.dart';

void main() {
  testWidgets('App launches without crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MapetiteApp()),
    );
    expect(find.text('Mapetite'), findsOneWidget);
  });
}
