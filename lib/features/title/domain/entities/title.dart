class Title {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const Title({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  Title copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Title(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
