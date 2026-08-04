import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/notifications/models/notification_model.dart';

void main() {
  group('AppNotification.fromJson', () {
    test('maps backend fields to model fields', () {
      final notification = AppNotification.fromJson({
        'id': 42,
        'title': 'Dining Budget Alert!',
        'message': "You've used 90% of your budget.",
        'is_read': false,
        'created_at': '2026-08-05T10:00:00Z',
        'updated_at': '2026-08-05T10:00:00Z',
      });

      expect(notification.id, '42');
      expect(notification.title, 'Dining Budget Alert!');
      expect(notification.body, "You've used 90% of your budget.");
      expect(notification.isRead, isFalse);
    });

    test('defaults is_read to false when absent', () {
      final notification = AppNotification.fromJson({
        'id': 1,
        'title': 'Welcome to Mapetite',
        'message': 'Thanks for joining!',
        'created_at': '2026-08-05T10:00:00Z',
      });

      expect(notification.isRead, isFalse);
    });
  });

  group('category inference from title', () {
    test('title containing "Budget" maps to budget category', () {
      final n = AppNotification(
        id: '1',
        title: 'Dining Budget Alert!',
        body: '',
        createdAt: DateTime.now(),
      );
      expect(n.category, NotificationCategory.budget);
    });

    test('title containing "recommend" maps to recommendation category', () {
      final n = AppNotification(
        id: '1',
        title: 'New recommendation for you',
        body: '',
        createdAt: DateTime.now(),
      );
      expect(n.category, NotificationCategory.recommendation);
    });

    test('title containing "grocery" maps to grocery category', () {
      final n = AppNotification(
        id: '1',
        title: "You're near a grocery store",
        body: '',
        createdAt: DateTime.now(),
      );
      expect(n.category, NotificationCategory.grocery);
    });

    test('unmatched title falls back to welcome category', () {
      final n = AppNotification(
        id: '1',
        title: 'Welcome to Mapetite',
        body: '',
        createdAt: DateTime.now(),
      );
      expect(n.category, NotificationCategory.welcome);
    });
  });

  group('timestamp formatting', () {
    test('just now for sub-minute age', () {
      final n = AppNotification(
        id: '1',
        title: '',
        body: '',
        createdAt: DateTime.now(),
      );
      expect(n.timestamp, 'Just now');
    });

    test('minutes ago for sub-hour age', () {
      final n = AppNotification(
        id: '1',
        title: '',
        body: '',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(n.timestamp, '5 mins ago');
    });

    test('yesterday for exactly one day old', () {
      final n = AppNotification(
        id: '1',
        title: '',
        body: '',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(n.timestamp, 'Yesterday');
    });
  });

  group('copyWith', () {
    test('flips isRead while preserving other fields', () {
      final original = AppNotification(
        id: '1',
        title: 'T',
        body: 'B',
        createdAt: DateTime(2026, 8, 1),
        isRead: false,
      );
      final updated = original.copyWith(isRead: true);

      expect(updated.isRead, isTrue);
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.createdAt, original.createdAt);
    });
  });
}
