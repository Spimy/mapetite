import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  final NotificationService _service = NotificationService();

  @override
  Future<List<AppNotification>> build() => _service.getNotifications();

  Future<void> markRead(String id) async {
    final current = await future;
    final previous = state;

    state = AsyncData([
      for (final n in current) if (n.id == id) n.copyWith(isRead: true) else n,
    ]);

    try {
      await _service.markRead(id);
    } catch (e) {
      state = previous;
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    final current = await future;
    final previous = state;
    final unreadIds = current.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    state = AsyncData([for (final n in current) n.copyWith(isRead: true)]);

    try {
      for (final id in unreadIds) {
        await _service.markRead(id);
      }
    } catch (e) {
      state = previous;
      rethrow;
    }
  }

  Future<void> dismiss(String id) async {
    final current = await future;
    final previous = state;

    state = AsyncData(current.where((n) => n.id != id).toList());

    try {
      await _service.dismiss(id);
    } catch (e) {
      state = previous;
      rethrow;
    }
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
  NotificationNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).value?.where((n) => !n.isRead).length ?? 0;
});
