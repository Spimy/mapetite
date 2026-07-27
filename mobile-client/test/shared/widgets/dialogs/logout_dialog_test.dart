import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/shared/services/storage_service.dart';
import 'package:mapetite/shared/widgets/dialogs/logout_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_access_token': 'fake-access',
      'auth_refresh_token': 'fake-refresh',
    });
    await StorageService.init();
  });

  testWidgets('renders logout icon, title, body, and Cancel/Sign Out buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: LogoutDialog())),
      ),
    );

    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.text('Sign out?'), findsOneWidget);
    expect(
      find.text("You'll need to sign in again to access your account."),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Cancel pops the dialog without clearing tokens', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, _) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showLogoutDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Login')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Sign out?'), findsNothing);
    expect(AuthTokenService.hasTokens, isTrue);
  });

  testWidgets(
    'Sign Out pops the dialog, clears tokens, and navigates to /login',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showLogoutDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (_, _) => const Scaffold(body: Text('Login')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(AuthTokenService.hasTokens, isTrue);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign out?'), findsNothing);
      expect(AuthTokenService.hasTokens, isFalse);
    },
  );
}
