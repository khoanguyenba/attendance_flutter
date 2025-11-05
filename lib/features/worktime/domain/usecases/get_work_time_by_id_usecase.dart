import 'package:attendance_system/features/worktime/domain/entities/app_work_time.dart';
import 'package:attendance_system/features/worktime/domain/repositories/app_work_time_repository.dart';

class GetWorkTimeByIdUseCase {
  final AppWorkTimeRepository repository;

  GetWorkTimeByIdUseCase(this.repository);

  Future<AppWorkTime?> execute(String id) async {
    return repository.getWorkTimeById(id);
  }
}
