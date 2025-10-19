class Department {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const Department({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  Department copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
