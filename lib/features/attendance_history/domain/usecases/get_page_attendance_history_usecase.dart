import 'package:attendance_system/features/attendance_history/domain/repositories/app_attendance_history_repository.dart';
import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class GetPageAttendanceHistoryUseCase {
  final AppAttendanceHistoryRepository repository;

  GetPageAttendanceHistoryUseCase(this.repository);

  Future<List<AppAttendanceHistory>> call({
    int pageIndex = 1,
    int pageSize = 20,
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getPageAttendanceHistory(
      pageIndex: pageIndex,
      pageSize: pageSize,
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
