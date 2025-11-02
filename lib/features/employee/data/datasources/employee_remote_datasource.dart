import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/core/data/models/common.dart';
import 'package:attendance_system/features/employee/data/models/employee_dto.dart';
import 'package:attendance_system/features/employee/data/models/create_employee_command.dart';
import 'package:attendance_system/features/employee/data/models/update_employee_command.dart';
import 'package:attendance_system/features/employee/data/models/get_page_employee_query.dart';

abstract class EmployeeRemoteDataSource {
  Future<EmployeeDto> createEmployee(CreateEmployeeCommand command);
  Future<void> updateEmployee(UpdateEmployeeCommand command);
  Future<EmployeeDto?> getEmployeeById(String id);
  Future<List<EmployeeDto>> getPageEmployee(GetPageEmployeeQuery query);
}

class EmployeeRemoteDataSourceImpl extends BaseRemoteDataSource
    implements EmployeeRemoteDataSource {
  EmployeeRemoteDataSourceImpl(super.dio, super.secureStorage);

  @override
  Future<EmployeeDto> createEmployee(CreateEmployeeCommand command) async {
    final response = await dio.post('/api/employees', data: command.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return EmployeeDto.fromJson(response.data);
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Create employee failed',
    );
  }

  @override
  Future<void> updateEmployee(UpdateEmployeeCommand command) async {
    final response = await dio.put(
      '/api/employees/${command.id}',
      data: command.toJson(),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Update employee failed',
      );
    }
  }

  @override
  Future<EmployeeDto?> getEmployeeById(String id) async {
    final response = await dio.get('/api/employees/$id');
    if (response.statusCode == 200) {
      return EmployeeDto.fromJson(response.data);
    }
    if (response.statusCode == 404) return null;
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get employee failed',
    );
  }

  @override
  Future<List<EmployeeDto>> getPageEmployee(GetPageEmployeeQuery query) async {
    final response = await dio.get(
      '/api/employees',
      queryParameters: query.toQueryParams(),
    );
    if (response.statusCode == 200) {
      final resp = response.data;
      if (resp is List) {
        return resp
            .map((e) => EmployeeDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (resp is Map<String, dynamic>) {
        dynamic items = resp['items'] ?? resp['data'] ?? resp['results'] ?? resp['rows'];
        if (items == null && resp.containsKey('data') && resp['data'] is Map) {
          final nested = resp['data'] as Map<String, dynamic>;
          items = nested['items'] ?? nested['data'];
        }
        if (items is List) {
          return items
              .map((e) => EmployeeDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [EmployeeDto.fromJson(resp)];
      }
      return [EmployeeDto.fromJson(Map<String, dynamic>.from(resp))];
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get employees failed',
    );
  }
}
