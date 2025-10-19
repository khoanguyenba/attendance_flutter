import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<String> createEmployee({
    required String fullName,
    required String code,
    required String email,
    int? gender,
    DateTime? birthDate,
    String? departmentId,
    String? titleId,
  });

  Future<List<Employee>> getEmployees({
    int pageNumber = 1,
    int pageSize = 10,
    String? code,
    String? fullName,
    String? departmentId,
    String? titleId,
  });

  Future<Employee> getEmployeeDetail(String id);

  Future<void> updateEmployee({
    required String id,
    required String fullName,
    required String code,
    int? gender,
    DateTime? birthDate,
    String? departmentId,
    String? titleId,
  });

  Future<List<EmployeeBasicInfo>> getEmployeeBasicInfo();
}
