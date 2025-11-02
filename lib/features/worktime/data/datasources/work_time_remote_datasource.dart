import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/core/data/models/common.dart';
import 'package:attendance_system/features/worktime/data/models/work_time_dto.dart';
import 'package:attendance_system/features/worktime/data/models/create_work_time_command.dart';
import 'package:attendance_system/features/worktime/data/models/update_work_time_command.dart';
import 'package:attendance_system/features/worktime/data/models/delete_work_time_command.dart';
import 'package:attendance_system/features/worktime/data/models/get_page_work_time_query.dart';

abstract class WorkTimeRemoteDataSource {
  Future<WorkTimeDto> createWorkTime(CreateWorkTimeCommand command);
  Future<void> updateWorkTime(UpdateWorkTimeCommand command);
  Future<void> deleteWorkTime(DeleteWorkTimeCommand command);
  Future<WorkTimeDto?> getWorkTimeById(String id);
  Future<List<WorkTimeDto>> getPageWorkTime(GetPageWorkTimeQuery query);
}

class WorkTimeRemoteDataSourceImpl extends BaseRemoteDataSource
    implements WorkTimeRemoteDataSource {
  WorkTimeRemoteDataSourceImpl(super.dio, super.secureStorage);

  @override
  Future<WorkTimeDto> createWorkTime(CreateWorkTimeCommand command) async {
    final response = await dio.post('/api/work-times', data: command.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return WorkTimeDto.fromJson(response.data);
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Create work time failed',
    );
  }

  @override
  Future<void> updateWorkTime(UpdateWorkTimeCommand command) async {
    final response = await dio.put(
      '/api/work-times/${command.id}',
      data: command.toJson(),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Update work time failed',
      );
    }
  }

  @override
  Future<void> deleteWorkTime(DeleteWorkTimeCommand command) async {
    final response = await dio.delete('/api/work-times/${command.id}');
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw ErrorDataException(
          message: response.data['message'] ?? 'Not found',
        );
      }
      throw ErrorDataException(
        message: response.data['message'] ?? 'Delete work time failed',
      );
    }
  }

  @override
  Future<WorkTimeDto?> getWorkTimeById(String id) async {
    final response = await dio.get('/api/work-times/$id');
    if (response.statusCode == 200) {
      return WorkTimeDto.fromJson(response.data);
    }
    if (response.statusCode == 404) return null;
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get work time failed',
    );
  }

  @override
  Future<List<WorkTimeDto>> getPageWorkTime(GetPageWorkTimeQuery query) async {
    final response = await dio.get(
      '/api/work-times',
      queryParameters: query.toQueryParams(),
    );
    if (response.statusCode == 200) {
      final resp = response.data;
      if (resp is List) {
        return resp
            .map((e) => WorkTimeDto.fromJson(e as Map<String, dynamic>))
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
              .map((e) => WorkTimeDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [WorkTimeDto.fromJson(resp)];
      }
      return [WorkTimeDto.fromJson(Map<String, dynamic>.from(resp))];
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get work times failed',
    );
  }
}
