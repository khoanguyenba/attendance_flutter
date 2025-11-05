import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

abstract class AppAttendanceHistoryRepository {
  Future<AppAttendanceHistory> createAttendanceHistory({
    required AttendanceType type,
    required AttendanceStatus status,
    required String workTimeId,
  });
  Future<void> deleteAttendanceHistory(String id);

  Future<AppAttendanceHistory?> getAttendanceHistoryById(String id);

  Future<List<AppAttendanceHistory>> getPageAttendanceHistory({
    int pageIndex = 1,
    int pageSize = 20,
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
