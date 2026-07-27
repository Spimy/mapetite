import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/shared/screens/legal_document_screen.dart';

void main() {
  testWidgets('renders the title and body text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LegalDocumentScreen(
          title: 'Terms of Service',
          body: 'Some legal body text.',
        ),
      ),
    );

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Some legal body text.'), findsOneWidget);
  });

  testWidgets('back button pops to the previous route', (tester) async {
    final router = GoRouter(
      initialLocation: '/about',
      routes: [
        GoRoute(
          path: '/about',
          builder: (_, _) => const Scaffold(body: Text('About')),
        ),
        GoRoute(
          path: '/about/terms',
          builder: (_, _) => const LegalDocumentScreen(
            title: 'Terms of Service',
            body: 'Body',
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/about/terms');
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
  });
}
