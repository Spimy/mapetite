import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/features/profile/models/user_profile.dart';
import 'package:mapetite/features/profile/providers/profile_provider.dart';
import 'package:mapetite/features/profile/screens/edit_profile_screen.dart';

UserProfile _profile() => const UserProfile(
      id: 'u1',
      username: 'jbonham',
      email: 'j@example.com',
      city: 'Bangsar',
      isHalal: true,
      allergens: ['Nuts'],
      healthGoal: 'general_health',
    );

class _FakeProfileNotifier extends ProfileNotifier {
  final UserProfile? _initial;
  final Object? _error;
  final Completer<void>? _gate;
  _FakeProfileNotifier({UserProfile? initial, Object? error, Completer<void>? gate})
      : _initial = initial,
        _error = error,
        _gate = gate;

  @override
  Future<UserProfile> build() async {
    if (_gate != null) await _gate.future;
    if (_error != null) throw _error;
    return _initial!;
  }
}

GoRouter _testRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const EditProfileScreen()),
      ],
    );

Widget _app(ProfileNotifier Function() notifier) => ProviderScope(
      overrides: [profileProvider.overrideWith(notifier)],
      child: MaterialApp.router(routerConfig: _testRouter()),
    );

void main() {
  testWidgets('shows a loading indicator while the profile is fetching', (tester) async {
    // A gate the fake notifier awaits inside build() lets the test hold it
    // in AsyncLoading deterministically, instead of racing a real pump()
    // against a build() that has no delay and could resolve before the
    // loading frame is ever observed.
    final gate = Completer<void>();
    await tester.pumpWidget(_app(
      () => _FakeProfileNotifier(initial: _profile(), gate: gate),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('renders real fetched data once loaded, not mock data', (tester) async {
    await tester.pumpWidget(_app(
      () => _FakeProfileNotifier(initial: _profile()),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.text('jbonham'), findsOneWidget);
    expect(find.text('Joshua Bonham'), findsNothing);
  });

  testWidgets('shows NetworkErrorState on fetch failure', (tester) async {
    // A real fetch failure surfaces as AppException(isNetworkError: true)
    // (see AppException.fromDio) — that's the error shape the widget's
    // `error is AppException && error.isNetworkError` branch checks for, so
    // the fake must throw the same shape a real network failure would.
    await tester.pumpWidget(_app(
      () => _FakeProfileNotifier(
        error: const AppException(
          message: 'network down',
          isNetworkError: true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Could not connect.'), findsOneWidget);
  });
}
