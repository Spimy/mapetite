import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super(NotificationMocks.items);

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markAllRead() {
    state = state.map((n) => AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          timestamp: n.timestamp,
          category: n.category,
          isRead: true,
        )).toList();
  }

  void markRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          timestamp: n.timestamp,
          category: n.category,
          isRead: true,
        );
      }
      return n;
    }).toList();
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>(
  (ref) => NotificationNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
