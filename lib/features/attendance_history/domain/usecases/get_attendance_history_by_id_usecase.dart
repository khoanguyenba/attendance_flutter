import 'package:attendance_system/features/attendance_history/domain/repositories/app_attendance_history_repository.dart';
import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class GetAttendanceHistoryByIdUseCase {
  final AppAttendanceHistoryRepository repository;

  GetAttendanceHistoryByIdUseCase(this.repository);

  Future<AppAttendanceHistory?> call(String id) async {
    return await repository.getAttendanceHistoryById(id);
  }
}
