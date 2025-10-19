import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/system_notification.dart';

class SystemNotificationModel extends SystemNotification {
  const SystemNotificationModel({
    required super.id,
    required super.title,
    super.content,
    required super.createdAt,
  });

  factory SystemNotificationModel.fromJson(Map<String, dynamic> json) {
    return SystemNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
