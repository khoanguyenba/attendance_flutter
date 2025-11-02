import 'package:attendance_system/features/department/domain/repositories/app_department_repository.dart';
import 'package:attendance_system/features/department/domain/entities/app_department.dart';

class CreateDepartmentUseCase {
  final AppDepartmentRepository repository;

  CreateDepartmentUseCase(this.repository);

  Future<AppDepartment> call({
    required String code,
    required String name,
    String? description,
  }) async {
    return await repository.createDepartment(
      code: code,
      name: name,
      description: description,
    );
  }
}
