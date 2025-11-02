import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/core/data/models/common.dart';
import 'package:attendance_system/features/department/data/models/department_dto.dart';
import 'package:attendance_system/features/department/data/models/create_department_command.dart';
import 'package:attendance_system/features/department/data/models/update_department_command.dart';
import 'package:attendance_system/features/department/data/models/delete_department_command.dart';
import 'package:attendance_system/features/department/data/models/get_page_department_query.dart';

abstract class DepartmentRemoteDataSource {
  Future<DepartmentDto> createDepartment(CreateDepartmentCommand command);
  Future<void> updateDepartment(UpdateDepartmentCommand command);
  Future<void> deleteDepartment(DeleteDepartmentCommand command);
  Future<DepartmentDto?> getDepartmentById(String id);
  Future<List<DepartmentDto>> getPageDepartment(GetPageDepartmentQuery query);
}

class DepartmentRemoteDataSourceImpl extends BaseRemoteDataSource
    implements DepartmentRemoteDataSource {
  DepartmentRemoteDataSourceImpl(super.dio, super.secureStorage);

  @override
  Future<DepartmentDto> createDepartment(
    CreateDepartmentCommand command,
  ) async {
    final response = await dio.post('/api/departments', data: command.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return DepartmentDto.fromJson(response.data);
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Create department failed',
    );
  }

  @override
  Future<void> updateDepartment(UpdateDepartmentCommand command) async {
    final response = await dio.put(
      '/api/departments/${command.id}',
      data: command.toJson(),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Update department failed',
      );
    }
  }

  @override
  Future<void> deleteDepartment(DeleteDepartmentCommand command) async {
    final response = await dio.delete('/api/departments/${command.id}');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Delete department failed',
      );
    }
  }

  @override
  Future<DepartmentDto?> getDepartmentById(String id) async {
    final response = await dio.get('/api/departments/$id');
    if (response.statusCode == 200) {
      return DepartmentDto.fromJson(response.data);
    }
    if (response.statusCode == 404) return null;
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get department failed',
    );
  }

  @override
  Future<List<DepartmentDto>> getPageDepartment(
    GetPageDepartmentQuery query,
  ) async {
    final response = await dio.get(
      '/api/departments',
      queryParameters: query.toQueryParams(),
    );
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data
          .map((e) => DepartmentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get departments failed',
    );
  }
}
