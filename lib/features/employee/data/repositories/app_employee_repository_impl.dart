import 'package:attendance_system/features/employee/data/datasources/employee_remote_datasource.dart';
import 'package:attendance_system/features/employee/data/models/create_employee_command.dart';
import 'package:attendance_system/features/employee/data/models/update_employee_command.dart';
import 'package:attendance_system/features/employee/data/models/get_page_employee_query.dart';
import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';
import 'package:attendance_system/features/employee/domain/repositories/app_employee_repository.dart';

class AppEmployeeRepositoryImpl implements AppEmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  AppEmployeeRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppEmployee> createEmployee({
    required String code,
    required String fullName,
    required String email,
    required Gender gender,
    required String departmentId,
    EmployeeStatus status = EmployeeStatus.active,
    String? managerId,
  }) async {
    final command = CreateEmployeeCommand(
      code: code,
      fullName: fullName,
      email: email,
      gender: gender,
      departmentId: departmentId,
      status: status,
      managerId: managerId,
    );
    final dto = await remoteDataSource.createEmployee(command);
    return AppEmployee(
      id: dto.id,
      code: dto.code,
      fullName: dto.fullName,
      email: dto.email,
      gender: dto.gender,
      departmentId: dto.departmentId,
      status: dto.status,
      managerId: dto.managerId,
    );
  }

  @override
  Future<void> updateEmployee({
    required String id,
    required String code,
    required String fullName,
    required String email,
    required Gender gender,
    required String departmentId,
    required EmployeeStatus status,
    String? managerId,
  }) async {
    final command = UpdateEmployeeCommand(
      id: id,
      code: code,
      fullName: fullName,
      email: email,
      gender: gender,
      departmentId: departmentId,
      status: status,
      managerId: managerId,
    );
    return await remoteDataSource.updateEmployee(command);
  }

  @override
  Future<AppEmployee?> getEmployeeById(String id) async {
    final dto = await remoteDataSource.getEmployeeById(id);
    if (dto == null) return null;
    return AppEmployee(
      id: dto.id,
      code: dto.code,
      fullName: dto.fullName,
      email: dto.email,
      gender: dto.gender,
      departmentId: dto.departmentId,
      status: dto.status,
      managerId: dto.managerId,
    );
  }

  @override
  Future<List<AppEmployee>> getPageEmployee({
    int pageIndex = 1,
    int pageSize = 20,
    String? code,
    String? fullName,
    String? email,
    String? departmentId,
  }) async {
    final query = GetPageEmployeeQuery(
      pageIndex: pageIndex,
      pageSize: pageSize,
      code: code,
      fullName: fullName,
      email: email,
      departmentId: departmentId,
    );
    final dtos = await remoteDataSource.getPageEmployee(query);
    return dtos
        .map(
          (dto) => AppEmployee(
            id: dto.id,
            code: dto.code,
            fullName: dto.fullName,
            email: dto.email,
            gender: dto.gender,
            departmentId: dto.departmentId,
            status: dto.status,
            managerId: dto.managerId,
            userId: dto.userId,
          ),
        )
        .toList();
  }
}
