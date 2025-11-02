import 'package:attendance_system/features/attendance_history/domain/repositories/app_attendance_history_repository.dart';
import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class CreateAttendanceHistoryUseCase {
  final AppAttendanceHistoryRepository repository;

  CreateAttendanceHistoryUseCase(this.repository);

  Future<AppAttendanceHistory> call({
    required AttendanceType type,
    required AttendanceStatus status,
  }) async {
    return await repository.createAttendanceHistory(type: type, status: status);
  }
}
