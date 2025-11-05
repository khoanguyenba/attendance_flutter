import 'package:attendance_system/features/department/domain/entities/app_department.dart';

class DepartmentDto extends AppDepartment {
  DepartmentDto({
    required super.id,
    required super.code,
    required super.name,
    super.description,
  });

  factory DepartmentDto.fromJson(Map<String, dynamic> json) {
    return DepartmentDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name, 'description': description};
  }

  AppDepartment toEntity() {
    return AppDepartment(
      id: id,
      code: code,
      name: name,
      description: description,
    );
  }
}
