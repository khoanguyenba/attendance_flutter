import 'package:attendance_system/features/department/domain/repositories/app_department_repository.dart';
import 'package:attendance_system/features/department/domain/entities/app_department.dart';

class GetDepartmentByIdUseCase {
  final AppDepartmentRepository repository;

  GetDepartmentByIdUseCase(this.repository);

  Future<AppDepartment?> call(String id) async {
    return await repository.getDepartmentById(id);
  }
}
