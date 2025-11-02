import 'package:attendance_system/features/employee/domain/repositories/app_employee_repository.dart';
import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

class UpdateEmployeeUseCase {
  final AppEmployeeRepository repository;

  UpdateEmployeeUseCase(this.repository);

  Future<void> call({
    required String id,
    required String code,
    required String fullName,
    required String email,
    required Gender gender,
    required String departmentId,
    required EmployeeStatus status,
    String? managerId,
  }) async {
    await repository.updateEmployee(
      id: id,
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
