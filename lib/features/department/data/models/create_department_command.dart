class CreateDepartmentCommand {
  final String code;
  final String name;
  final String? description;

  CreateDepartmentCommand({
    required this.code,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'description': description,
  };
}
