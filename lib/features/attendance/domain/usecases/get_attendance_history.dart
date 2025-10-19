import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceHistory {
  final AttendanceRepository repository;

  GetAttendanceHistory(this.repository);

  Future<List<Attendance>> call({
    String? employeeId,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? day,
    int? year,
    int? month,
    String? location,
  }) async {
    return await repository.getAttendanceHistory(
      employeeId: employeeId,
      fromDate: fromDate,
      toDate: toDate,
      day: day,
      year: year,
      month: month,
      location: location,
    );
  }
}
