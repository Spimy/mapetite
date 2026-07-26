import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/routes/app_router.dart';
import 'package:mapetite/shared/widgets/dialogs/session_expired_dialog.dart';

void main() {
  testWidgets('renders lock icon, title, body, and a Sign In button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SessionExpiredDialog())),
    );

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Please sign in again to continue.'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets(
    'showSessionExpiredDialog surfaces the dialog via the global navigator key, and Sign In pops it and navigates to /login',
    (tester) async {
      final router = GoRouter(
        navigatorKey: appNavigatorKey,
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, _) => const Scaffold(body: Text('Login')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      showSessionExpiredDialog();
      await tester.pumpAndSettle();

      expect(find.text('Session expired'), findsOneWidget);

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Session expired'), findsNothing);
    },
  );
}
