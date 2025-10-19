class SystemNotification {
  final String id;
  final String title;
  final String? content;
  final DateTime createdAt;

  const SystemNotification({
    required this.id,
    required this.title,
    this.content,
    required this.createdAt,
  });

  SystemNotification copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return SystemNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
