import 'package:attendance_system/features/employee/domain/repositories/app_employee_repository.dart';
import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

class GetPageEmployeeUseCase {
  final AppEmployeeRepository repository;

  GetPageEmployeeUseCase(this.repository);

  Future<List<AppEmployee>> call({
    int pageIndex = 1,
    int pageSize = 20,
    String? code,
    String? fullName,
    String? email,
    String? departmentId,
  }) async {
    return await repository.getPageEmployee(
      pageIndex: pageIndex,
      pageSize: pageSize,
      code: code,
      fullName: fullName,
      email: email,
      departmentId: departmentId,
    );
  }
}
