import 'package:attendance_system/features/worktime/domain/repositories/app_work_time_repository.dart';

class UpdateWorkTimeUseCase {
  final AppWorkTimeRepository repository;

  UpdateWorkTimeUseCase(this.repository);

  Future<void> execute({
    required String id,
    required String name,
    required String validCheckInTime,
    required String validCheckOutTime,
    required bool isActive,
  }) async {
    return repository.updateWorkTime(
      id: id,
      name: name,
      validCheckInTime: validCheckInTime,
      validCheckOutTime: validCheckOutTime,
      isActive: isActive,
    );
  }
}
