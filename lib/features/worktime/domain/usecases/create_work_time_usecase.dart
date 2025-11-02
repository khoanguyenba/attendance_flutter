import 'package:attendance_system/features/worktime/domain/entities/app_work_time.dart';
import 'package:attendance_system/features/worktime/domain/repositories/app_work_time_repository.dart';

class CreateWorkTimeUseCase {
  final AppWorkTimeRepository repository;

  CreateWorkTimeUseCase(this.repository);

  Future<AppWorkTime> execute({
    required String name,
    required String validCheckInTime,
    required String validCheckOutTime,
    required bool isActive,
  }) async {
    return repository.createWorkTime(
      name: name,
      validCheckInTime: validCheckInTime,
      validCheckOutTime: validCheckOutTime,
      isActive: isActive,
    );
  }
}
