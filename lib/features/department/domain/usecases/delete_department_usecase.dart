import 'package:attendance_system/features/department/domain/repositories/app_department_repository.dart';

class DeleteDepartmentUseCase {
  final AppDepartmentRepository repository;

  DeleteDepartmentUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteDepartment(id);
  }
}
