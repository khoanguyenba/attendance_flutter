import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/core/data/models/common.dart';
import 'package:attendance_system/features/attendance_history/data/models/attendance_history_dto.dart';
import 'package:attendance_system/features/attendance_history/data/models/create_attendance_history_command.dart';
import 'package:attendance_system/features/attendance_history/data/models/delete_attendance_history_command.dart';
import 'package:attendance_system/features/attendance_history/data/models/get_page_attendance_history_query.dart';

abstract class AttendanceHistoryRemoteDataSource {
  Future<AttendanceHistoryDto> createAttendanceHistory(
    CreateAttendanceHistoryCommand command,
  );
  // Update is not supported by the current API (only create/get/page).
  Future<void> deleteAttendanceHistory(DeleteAttendanceHistoryCommand command);
  Future<AttendanceHistoryDto?> getAttendanceHistoryById(String id);
  Future<List<AttendanceHistoryDto>> getPageAttendanceHistory(
    GetPageAttendanceHistoryQuery query,
  );
}

class AttendanceHistoryRemoteDataSourceImpl extends BaseRemoteDataSource
    implements AttendanceHistoryRemoteDataSource {
  AttendanceHistoryRemoteDataSourceImpl(super.dio, super.secureStorage);

  @override
  Future<AttendanceHistoryDto> createAttendanceHistory(
    CreateAttendanceHistoryCommand command,
  ) async {
    final response = await dio.post(
      '/api/attendance-histories',
      data: command.toJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return AttendanceHistoryDto.fromJson(response.data);
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Create attendance history failed',
    );
  }

  @override
  Future<void> deleteAttendanceHistory(
    DeleteAttendanceHistoryCommand command,
  ) async {
    final response = await dio.delete(
      '/api/attendance-histories/${command.id}',
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Delete attendance history failed',
      );
    }
  }

  @override
  Future<AttendanceHistoryDto?> getAttendanceHistoryById(String id) async {
    final response = await dio.get('/api/attendance-histories/$id');
    if (response.statusCode == 200) {
      return AttendanceHistoryDto.fromJson(response.data);
    }
    if (response.statusCode == 404) return null;
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get attendance history failed',
    );
  }

  @override
  Future<List<AttendanceHistoryDto>> getPageAttendanceHistory(
    GetPageAttendanceHistoryQuery query,
  ) async {
    final response = await dio.get(
      '/api/attendance-histories',
      queryParameters: query.toQueryParams(),
    );
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data
          .map((e) => AttendanceHistoryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Get attendance histories failed',
    );
  }
}
