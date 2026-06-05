import '../models/notification_model.dart';

class NotificationService {
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return NotificationMocks.items;
    // TODO: Replace with real API call to GET /api/v1/notifications/
  }

  Future<void> markAllRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Call PATCH /api/v1/notifications/read-all
  }

  Future<void> dismissNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // TODO: Call DELETE /api/v1/notifications/:id
  }
}
