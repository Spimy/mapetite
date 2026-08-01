import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/features/profile/models/user_profile.dart'
    as profile_models;
import 'package:mapetite/features/profile/providers/profile_provider.dart';
import 'package:mapetite/features/auth/controllers/auth_controller.dart';
import 'package:mapetite/features/auth/models/auth_state.dart';
import 'package:mapetite/features/auth/models/current_user.dart';
import 'package:mapetite/features/auth/services/auth_service.dart';

profile_models.UserProfile _profile({String username = 'jbonham'}) =>
    profile_models.UserProfile(
      id: 'u1',
      username: username,
      email: 'j@example.com',
      isHalal: false,
    );

class _FakeProfileNotifier extends ProfileNotifier {
  final profile_models.UserProfile _initial;
  _FakeProfileNotifier(this._initial);

  @override
  Future<profile_models.UserProfile> build() async => _initial;
}

class _NeverAuthenticatesService extends AuthService {}

class _TestAuthController extends AuthController {
  _TestAuthController() : super(_NeverAuthenticatesService());

  void setCurrentUser(CurrentUser user) {
    state = state.copyWith(currentUser: user);
  }
}

CurrentUser _fakeCurrentUser() => const CurrentUser(
      id: 1,
      email: 'j@example.com',
      username: 'jbonham',
      firstName: 'Josh',
      lastName: 'Bonham',
      isVerified: true,
      profile: UserProfile(
        onboardingCompleted: true,
        avatar: null,
        phoneNumber: '',
        address: '',
        city: '',
        country: '',
        spendingAlertPercent: 80,
        healthGoal: '',
        activityLevel: '',
        isHalal: false,
        isVegan: false,
        allergies: [],
      ),
    );

void main() {
  test('build() surfaces the initial state as data', () async {
    final container = ProviderContainer(overrides: [
      profileProvider.overrideWith(() => _FakeProfileNotifier(_profile())),
    ]);
    addTearDown(container.dispose);

    final state = await container.read(profileProvider.future);

    expect(state.username, 'jbonham');
  });

  test('updateUsername stages the change locally without a network call', () async {
    final container = ProviderContainer(overrides: [
      profileProvider.overrideWith(() => _FakeProfileNotifier(_profile())),
    ]);
    addTearDown(container.dispose);
    await container.read(profileProvider.future);

    container.read(profileProvider.notifier).updateUsername('newname');

    final state = container.read(profileProvider).value!;
    expect(state.username, 'newname');
  });

  test('updateDietary stages allergens locally', () async {
    final container = ProviderContainer(overrides: [
      profileProvider.overrideWith(() => _FakeProfileNotifier(_profile())),
    ]);
    addTearDown(container.dispose);
    await container.read(profileProvider.future);

    container
        .read(profileProvider.notifier)
        .updateDietary(isHalal: true, allergens: ['Nuts']);

    final state = container.read(profileProvider).value!;
    expect(state.isHalal, isTrue);
    expect(state.allergens, ['Nuts']);
  });

  test('saveChanges propagates a failure instead of silently succeeding', () async {
    // The fake notifier's build() never talks to the network, and
    // saveChanges() inherits the real ProfileNotifier implementation, which
    // does call ProfileService — with no reachable backend in this unit
    // test, the PATCH must fail and the failure must surface, not be
    // swallowed the way the old Future.delayed stub always returned true.
    final container = ProviderContainer(overrides: [
      profileProvider.overrideWith(() => _FakeProfileNotifier(_profile())),
    ]);
    addTearDown(container.dispose);
    await container.read(profileProvider.future);

    container.read(profileProvider.notifier).updateUsername('newname');

    await expectLater(
      container.read(profileProvider.notifier).saveChanges(),
      throwsA(anything),
    );

    // Deliberately does NOT roll back — the user's staged edit stays visible
    // so they can retry Save without re-entering everything.
    final state = container.read(profileProvider).value!;
    expect(state.username, 'newname');
  });

  test(
    'profileProvider recovers automatically once auth resolves, without a manual retry',
    () async {
      final testAuthController = _TestAuthController();
      final container = ProviderContainer(overrides: [
        authControllerProvider.overrideWith((ref) => testAuthController),
      ]);
      addTearDown(container.dispose);

      // currentUser starts null: profileProvider.build() must not succeed yet.
      await container.read(profileProvider.future).catchError((_) => _profile());
      final beforeState = container.read(profileProvider);
      expect(beforeState.hasError, isTrue);
      expect(beforeState.error, isA<StateError>());

      // Auth resolves — because profileProvider now watches authControllerProvider
      // (not a one-shot read), it must rebuild on its own.
      testAuthController.setCurrentUser(_fakeCurrentUser());
      await container.read(profileProvider.future).catchError((_) => _profile());

      final afterState = container.read(profileProvider);
      // No live backend in this unit test, so the real ProfileService.getProfile()
      // call still fails — but it must now fail with a network exception, not the
      // old StateError, proving build() got past the currentUser-null gate.
      expect(afterState.hasError, isTrue);
      expect(afterState.error, isNot(isA<StateError>()));
    },
  );
}
