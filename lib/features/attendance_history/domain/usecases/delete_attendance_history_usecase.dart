import 'package:attendance_system/features/attendance_history/domain/repositories/app_attendance_history_repository.dart';

class DeleteAttendanceHistoryUseCase {
  final AppAttendanceHistoryRepository repository;

  DeleteAttendanceHistoryUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteAttendanceHistory(id);
  }
}
