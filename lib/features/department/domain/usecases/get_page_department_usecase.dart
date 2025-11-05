import 'package:attendance_system/features/department/domain/repositories/app_department_repository.dart';
import 'package:attendance_system/features/department/domain/entities/app_department.dart';

class GetPageDepartmentUseCase {
  final AppDepartmentRepository repository;

  GetPageDepartmentUseCase(this.repository);

  Future<List<AppDepartment>> call({
    int pageIndex = 1,
    int pageSize = 20,
    String? code,
    String? name,
  }) async {
    return await repository.getPageDepartment(
      pageIndex: pageIndex,
      pageSize: pageSize,
      code: code,
      name: name,
    );
  }
}
