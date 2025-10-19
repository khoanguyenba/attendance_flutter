import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createEmployee({
    required String fullName,
    required String code,
    required String email,
    int? gender,
    DateTime? birthDate,
    String? departmentId,
    String? titleId,
  }) async {
    final data = {
      'fullName': fullName,
      'code': code,
      'email': email,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
      if (departmentId != null) 'departmentId': departmentId,
      if (titleId != null) 'titleId': titleId,
    };

    return await remoteDataSource.createEmployee(data);
  }

  @override
  Future<List<Employee>> getEmployees({
    int pageNumber = 1,
    int pageSize = 10,
    String? code,
    String? fullName,
    String? departmentId,
    String? titleId,
  }) async {
    final params = {
      'PageNumber': pageNumber,
      'PageSize': pageSize,
      if (code != null) 'Code': code,
      if (fullName != null) 'FullName': fullName,
      if (departmentId != null) 'DepartmentId': departmentId,
      if (titleId != null) 'TitleId': titleId,
    };

    final models = await remoteDataSource.getEmployees(params);
    return models;
  }

  @override
  Future<Employee> getEmployeeDetail(String id) async {
    return await remoteDataSource.getEmployeeDetail(id);
  }

  @override
  Future<void> updateEmployee({
    required String id,
    required String fullName,
    required String code,
    int? gender,
    DateTime? birthDate,
    String? departmentId,
    String? titleId,
  }) async {
    final data = {
      'id': id,
      'fullName': fullName,
      'code': code,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
      if (departmentId != null) 'departmentId': departmentId,
      if (titleId != null) 'titleId': titleId,
    };

    await remoteDataSource.updateEmployee(id, data);
  }

  @override
  Future<List<EmployeeBasicInfo>> getEmployeeBasicInfo() async {
    return await remoteDataSource.getEmployeeBasicInfo();
  }
}
