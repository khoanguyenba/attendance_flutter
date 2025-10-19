import '../entities/system_notification.dart';
import '../repositories/system_notification_repository.dart';

class GetSystemNotifications {
  final SystemNotificationRepository repository;

  GetSystemNotifications({required this.repository});

  Future<List<SystemNotification>> call({
    required String receiverId,
    required int pageNumber,
    required int pageSize,
  }) async {
    return await repository.getSystemNotifications(
      receiverId: receiverId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
