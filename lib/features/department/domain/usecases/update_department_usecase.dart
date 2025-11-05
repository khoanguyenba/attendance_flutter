import 'package:attendance_system/features/department/domain/repositories/app_department_repository.dart';

class UpdateDepartmentUseCase {
  final AppDepartmentRepository repository;

  UpdateDepartmentUseCase(this.repository);

  Future<void> call({
    required String id,
    required String code,
    required String name,
    String? description,
  }) async {
    await repository.updateDepartment(
      id: id,
      code: code,
      name: name,
      description: description,
    );
  }
}
