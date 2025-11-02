import 'package:attendance_system/features/worktime/domain/entities/app_work_time.dart';
import 'package:attendance_system/features/worktime/domain/repositories/app_work_time_repository.dart';

class GetPageWorkTimeUseCase {
  final AppWorkTimeRepository repository;

  GetPageWorkTimeUseCase(this.repository);

  Future<List<AppWorkTime>> execute({
    int pageIndex = 1,
    int pageSize = 20,
    String? name,
    bool? isActive,
  }) async {
    return repository.getPageWorkTime(
      pageIndex: pageIndex,
      pageSize: pageSize,
      name: name,
      isActive: isActive,
    );
  }
}
