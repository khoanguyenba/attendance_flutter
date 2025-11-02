import 'package:attendance_system/features/worktime/domain/repositories/app_work_time_repository.dart';

class DeleteWorkTimeUseCase {
  final AppWorkTimeRepository repository;

  DeleteWorkTimeUseCase(this.repository);

  Future<void> execute(String id) async {
    return repository.deleteWorkTime(id);
  }
}
