import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/features/profile/models/user_profile.dart';
import 'package:mapetite/features/profile/providers/profile_provider.dart';

UserProfile _profile({String username = 'jbonham'}) => UserProfile(
      id: 'u1',
      username: username,
      email: 'j@example.com',
      isHalal: false,
    );

class _FakeProfileNotifier extends ProfileNotifier {
  final UserProfile _initial;
  _FakeProfileNotifier(this._initial);

  @override
  Future<UserProfile> build() async => _initial;
}

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
}
