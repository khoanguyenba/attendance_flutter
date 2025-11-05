import 'package:attendance_system/features/employee/domain/repositories/app_employee_repository.dart';
import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

class CreateEmployeeUseCase {
  final AppEmployeeRepository repository;

  CreateEmployeeUseCase(this.repository);

  Future<AppEmployee> call({
    required String code,
    required String fullName,
    required String email,
    required Gender gender,
    required String departmentId,
    EmployeeStatus status = EmployeeStatus.active,
    String? managerId,
  }) async {
    return await repository.createEmployee(
      code: code,
      fullName: fullName,
      email: email,
      gender: gender,
      departmentId: departmentId,
      status: status,
      managerId: managerId,
    );
  }
}
