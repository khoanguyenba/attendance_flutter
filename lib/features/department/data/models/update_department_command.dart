class UpdateDepartmentCommand {
  final String id;
  final String code;
  final String name;
  final String? description;

  UpdateDepartmentCommand({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'description': description,
  };
}
