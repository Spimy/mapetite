import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/notifications/models/notification_model.dart';
import 'package:mapetite/features/notifications/providers/notification_provider.dart';
import 'package:mapetite/features/notifications/screens/notification_centre_screen.dart';

AppNotification _n(String id, {bool isRead = false, String title = 'Budget Alert'}) =>
    AppNotification(
      id: id,
      title: title,
      body: 'body text',
      createdAt: DateTime.now(),
      isRead: isRead,
    );

class _FixedNotificationNotifier extends NotificationNotifier {
  final List<AppNotification> _state;
  _FixedNotificationNotifier(this._state);

  @override
  Future<List<AppNotification>> build() async => _state;
}

class _CountingNotificationNotifier extends NotificationNotifier {
  final List<AppNotification> _state;
  int buildCount = 0;
  _CountingNotificationNotifier(this._state);

  @override
  Future<List<AppNotification>> build() async {
    buildCount++;
    return _state;
  }
}

Widget _wrap(List<AppNotification> notifications) => ProviderScope(
      overrides: [
        notificationProvider.overrideWith(() => _FixedNotificationNotifier(notifications)),
      ],
      child: const MaterialApp(home: NotificationCentreScreen()),
    );

void main() {
  testWidgets('renders each notification title and body', (tester) async {
    await tester.pumpWidget(_wrap([
      _n('a', title: 'Dining Budget Alert!'),
      _n('b', title: 'Welcome to Mapetite'),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Dining Budget Alert!'), findsOneWidget);
    expect(find.text('Welcome to Mapetite'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no notifications', (tester) async {
    await tester.pumpWidget(_wrap([]));
    await tester.pumpAndSettle();

    expect(find.text('All caught up'), findsOneWidget);
  });

  testWidgets('"Mark all read" only appears when something is unread', (tester) async {
    await tester.pumpWidget(_wrap([_n('a', isRead: true)]));
    await tester.pumpAndSettle();

    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('refetches notifications when the screen is opened', (tester) async {
    final notifier = _CountingNotificationNotifier([_n('a')]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        notificationProvider.overrideWith(() => notifier),
      ],
      child: const MaterialApp(home: NotificationCentreScreen()),
    ));
    await tester.pumpAndSettle();

    expect(notifier.buildCount, 2);
  });
}
