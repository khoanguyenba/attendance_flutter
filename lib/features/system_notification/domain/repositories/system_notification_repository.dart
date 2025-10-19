import '../entities/system_notification.dart';

abstract class SystemNotificationRepository {
  Future<List<SystemNotification>> getSystemNotifications({
    required String receiverId,
    required int pageNumber,
    required int pageSize,
  });
}
