import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

abstract class AppEmployeeRepository {
  Future<AppEmployee> createEmployee({
    required String code,
    required String fullName,
    required String email,
    required Gender gender,
    required String departmentId,
    EmployeeStatus status = EmployeeStatus.active,
    String? managerId,
  });

  Future<void> updateEmployee({
    required String id,
    required String code,
    required String fullName,
    required String email,
    required Gender gender,
    required String departmentId,
    required EmployeeStatus status,
    String? managerId,
  });

  Future<AppEmployee?> getEmployeeById(String id);

  Future<List<AppEmployee>> getPageEmployee({
    int pageIndex = 1,
    int pageSize = 20,
    String? code,
    String? fullName,
    String? email,
    String? departmentId,
  });
}
