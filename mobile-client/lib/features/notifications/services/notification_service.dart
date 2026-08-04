import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  Future<List<AppNotification>> getNotifications() async {
    final response = await ApiClient.get(ApiEndpoints.notifications);
    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
  }

  Future<void> markRead(String id) async {
    await ApiClient.patch(
      ApiEndpoints.notificationDetail(id),
      data: {'is_read': true},
    );
  }

  Future<void> dismiss(String id) async {
    await ApiClient.delete(ApiEndpoints.notificationDetail(id));
  }
}
