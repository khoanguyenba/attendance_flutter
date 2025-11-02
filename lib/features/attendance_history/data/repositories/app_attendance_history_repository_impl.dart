import 'package:attendance_system/features/attendance_history/data/datasources/attendance_history_remote_datasource.dart';
import 'package:attendance_system/features/attendance_history/data/models/create_attendance_history_command.dart';
import 'package:attendance_system/features/attendance_history/data/models/delete_attendance_history_command.dart';
import 'package:attendance_system/features/attendance_history/data/models/get_page_attendance_history_query.dart';
import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';
import 'package:attendance_system/features/attendance_history/domain/repositories/app_attendance_history_repository.dart';

class AppAttendanceHistoryRepositoryImpl
    implements AppAttendanceHistoryRepository {
  final AttendanceHistoryRemoteDataSource remoteDataSource;

  AppAttendanceHistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppAttendanceHistory> createAttendanceHistory({
    required AttendanceType type,
    required AttendanceStatus status,
  }) async {
    final command = CreateAttendanceHistoryCommand(type: type, status: status);
    final dto = await remoteDataSource.createAttendanceHistory(command);
    return AppAttendanceHistory(
      id: dto.id,
      employeeId: dto.employeeId,
      attendanceDate: dto.attendanceDate,
      type: dto.type,
      status: dto.status,
    );
  }

  // Update is not supported by the current API (only create/get/page/delete).

  @override
  Future<void> deleteAttendanceHistory(String id) async {
    await remoteDataSource.deleteAttendanceHistory(
      DeleteAttendanceHistoryCommand(id),
    );
  }

  @override
  Future<AppAttendanceHistory?> getAttendanceHistoryById(String id) async {
    final dto = await remoteDataSource.getAttendanceHistoryById(id);
    if (dto == null) return null;
    return AppAttendanceHistory(
      id: dto.id,
      employeeId: dto.employeeId,
      attendanceDate: dto.attendanceDate,
      type: dto.type,
      status: dto.status,
    );
  }

  @override
  Future<List<AppAttendanceHistory>> getPageAttendanceHistory({
    int pageIndex = 1,
    int pageSize = 20,
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = GetPageAttendanceHistoryQuery(
      pageIndex: pageIndex,
      pageSize: pageSize,
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
    );
    final dtos = await remoteDataSource.getPageAttendanceHistory(query);
    return dtos
        .map(
          (dto) => AppAttendanceHistory(
            id: dto.id,
            employeeId: dto.employeeId,
            attendanceDate: dto.attendanceDate,
            type: dto.type,
            status: dto.status,
          ),
        )
        .toList();
  }
}
