import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/system_notification_model.dart';

abstract class SystemNotificationRemoteDataSource {
  Future<List<SystemNotificationModel>> getSystemNotifications({
    required String receiverId,
    required int pageNumber,
    required int pageSize,
  });
}

class SystemNotificationRemoteDataSourceImpl implements SystemNotificationRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'system_notifications';

  @override
  Future<List<SystemNotificationModel>> getSystemNotifications({
    required String receiverId,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final query = _firestore
          .collection(_collection)
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('createdAt', descending: true);

      // Firestore's `offset` was removed in newer SDKs. To emulate paging by
      // page number we request a larger window and then take the desired slice
      // on the client. This is less efficient than cursor-based pagination but
      // keeps the existing API contract (pageNumber/pageSize).
      final int fetchCount = (pageNumber + 1) * pageSize;
      final querySnapshot = await query.limit(fetchCount).get();

      final docs = querySnapshot.docs
          .skip(pageNumber * pageSize)
          .take(pageSize)
          .toList();

      return docs.map((doc) {
        final data = doc.data();
        return SystemNotificationModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get system notifications: $e');
    }
  }
}
