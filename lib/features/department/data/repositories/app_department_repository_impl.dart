import 'package:attendance_system/features/department/data/datasources/department_remote_datasource.dart';
import 'package:attendance_system/features/department/data/models/create_department_command.dart';
import 'package:attendance_system/features/department/data/models/delete_department_command.dart';
import 'package:attendance_system/features/department/data/models/update_department_command.dart';
import 'package:attendance_system/features/department/data/models/get_page_department_query.dart';
import 'package:attendance_system/features/department/domain/entities/app_department.dart';
import 'package:attendance_system/features/department/domain/repositories/app_department_repository.dart';

class AppDepartmentRepositoryImpl implements AppDepartmentRepository {
  final DepartmentRemoteDataSource remoteDataSource;

  AppDepartmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppDepartment> createDepartment({
    required String code,
    required String name,
    String? description,
  }) async {
    final command = CreateDepartmentCommand(
      code: code,
      name: name,
      description: description,
    );
    final dto = await remoteDataSource.createDepartment(command);
    return AppDepartment(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      description: dto.description,
    );
  }

  @override
  Future<void> updateDepartment({
    required String id,
    required String code,
    required String name,
    String? description,
  }) async {
    final command = UpdateDepartmentCommand(
      id: id,
      code: code,
      name: name,
      description: description,
    );
    await remoteDataSource.updateDepartment(command);
  }

  @override
  Future<void> deleteDepartment(String id) async {
    await remoteDataSource.deleteDepartment(DeleteDepartmentCommand(id));
  }

  @override
  Future<AppDepartment?> getDepartmentById(String id) async {
    final dto = await remoteDataSource.getDepartmentById(id);
    if (dto == null) return null;
    return AppDepartment(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      description: dto.description,
    );
  }

  @override
  Future<List<AppDepartment>> getPageDepartment({
    int pageIndex = 1,
    int pageSize = 20,
    String? code,
    String? name,
  }) async {
    final query = GetPageDepartmentQuery(
      pageIndex: pageIndex,
      pageSize: pageSize,
      code: code,
      name: name,
    );
    final dtos = await remoteDataSource.getPageDepartment(query);
    return dtos
        .map(
          (dto) => AppDepartment(
            id: dto.id,
            code: dto.code,
            name: dto.name,
            description: dto.description,
          ),
        )
        .toList();
  }
}
