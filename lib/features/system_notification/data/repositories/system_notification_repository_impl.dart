import '../../domain/entities/system_notification.dart';
import '../../domain/repositories/system_notification_repository.dart';
import '../datasources/system_notification_remote_datasource.dart';

class SystemNotificationRepositoryImpl implements SystemNotificationRepository {
  final SystemNotificationRemoteDataSource remoteDataSource;

  SystemNotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SystemNotification>> getSystemNotifications({
    required String receiverId,
    required int pageNumber,
    required int pageSize,
  }) async {
    return await remoteDataSource.getSystemNotifications(
      receiverId: receiverId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
