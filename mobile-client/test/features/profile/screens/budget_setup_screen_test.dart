import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/profile/screens/budget_setup_screen.dart';

void main() {
  testWidgets(
      'edit-mode Done button pops immediately without touching the network '
      '(budget saving is deferred to Edit Profile\'s Save Changes button)',
      (tester) async {
    // Regression test for a double-save bug: this screen used to call
    // budgetProvider.adjustBudget() directly on Done, then Edit Profile's
    // Save Changes would send the same budget fields again via
    // profileProvider. If this button still touched the network, the tap
    // below would throw (Flutter's test HttpClient always returns 400) and
    // the screen would never pop.
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (_, _) => const Scaffold(body: Text('Start')),
        ),
        GoRoute(
          path: '/profile/budget-setup',
          builder: (_, _) => const BudgetSetupScreen(isEditMode: true),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);

    // Simulate Edit Profile pushing into this screen, exactly as
    // EditProfileScreen._navigateToBudget does via context.push(...).
    router.push('/profile/budget-setup');
    await tester.pumpAndSettle();
    expect(find.text('Budget Settings'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
  });
}
