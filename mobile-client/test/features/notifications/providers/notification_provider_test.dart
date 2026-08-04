import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/features/notifications/models/notification_model.dart';
import 'package:mapetite/features/notifications/providers/notification_provider.dart';

AppNotification _n(String id, {bool isRead = false, String title = 'Budget Alert'}) =>
    AppNotification(
      id: id,
      title: title,
      body: 'body',
      createdAt: DateTime(2026, 8, 1),
      isRead: isRead,
    );

class _FakeNotificationNotifier extends NotificationNotifier {
  final List<AppNotification> _initial;
  _FakeNotificationNotifier(this._initial);

  @override
  Future<List<AppNotification>> build() async => _initial;
}

void main() {
  test('build() surfaces the initial list as data', () async {
    final container = ProviderContainer(overrides: [
      notificationProvider.overrideWith(() => _FakeNotificationNotifier([_n('a')])),
    ]);
    addTearDown(container.dispose);

    final state = await container.read(notificationProvider.future);

    expect(state.single.id, 'a');
  });

  test('unreadCountProvider counts only unread notifications', () async {
    final container = ProviderContainer(overrides: [
      notificationProvider.overrideWith(() => _FakeNotificationNotifier([
            _n('a', isRead: false),
            _n('b', isRead: true),
            _n('c', isRead: false),
          ])),
    ]);
    addTearDown(container.dispose);
    await container.read(notificationProvider.future);

    expect(container.read(unreadCountProvider), 2);
  });

  test(
      'markRead marks the notification read locally before the API call '
      'resolves, then rolls back on failure', () async {
    final container = ProviderContainer(overrides: [
      notificationProvider.overrideWith(() => _FakeNotificationNotifier([_n('a', isRead: false)])),
    ]);
    addTearDown(container.dispose);
    await container.read(notificationProvider.future);

    final future = container.read(notificationProvider.notifier).markRead('a');

    // `await` always yields at least one microtask before resuming, so give
    // the event loop a tick before checking the optimistic update landed.
    await Future<void>.delayed(Duration.zero);
    final optimistic = container.read(notificationProvider).value!;
    expect(optimistic.single.isRead, isTrue);

    // No reachable backend in this unit test (flutter test's HttpOverrides
    // makes every real HttpClient fail), so state should roll back.
    await future.catchError((_) {});
    final rolledBack = container.read(notificationProvider).value!;
    expect(rolledBack.single.isRead, isFalse);
  });

  test(
      'dismiss removes the notification locally before the API call '
      'resolves, then rolls back on failure', () async {
    final container = ProviderContainer(overrides: [
      notificationProvider.overrideWith(() => _FakeNotificationNotifier([_n('a'), _n('b')])),
    ]);
    addTearDown(container.dispose);
    await container.read(notificationProvider.future);

    final future = container.read(notificationProvider.notifier).dismiss('a');

    await Future<void>.delayed(Duration.zero);
    final optimistic = container.read(notificationProvider).value!;
    expect(optimistic.any((n) => n.id == 'a'), isFalse);

    await future.catchError((_) {});
    final rolledBack = container.read(notificationProvider).value!;
    expect(rolledBack.length, 2);
  });

  test(
      'markAllRead marks every unread notification read locally, then '
      'rolls back on failure', () async {
    final container = ProviderContainer(overrides: [
      notificationProvider.overrideWith(() => _FakeNotificationNotifier([
            _n('a', isRead: false),
            _n('b', isRead: false),
          ])),
    ]);
    addTearDown(container.dispose);
    await container.read(notificationProvider.future);

    final future = container.read(notificationProvider.notifier).markAllRead();

    await Future<void>.delayed(Duration.zero);
    final optimistic = container.read(notificationProvider).value!;
    expect(optimistic.every((n) => n.isRead), isTrue);

    await future.catchError((_) {});
    final rolledBack = container.read(notificationProvider).value!;
    expect(rolledBack.every((n) => n.isRead), isFalse);
  });
}
