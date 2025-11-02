import 'package:attendance_system/features/worktime/domain/entities/app_work_time.dart';

abstract class AppWorkTimeRepository {
  Future<AppWorkTime> createWorkTime({
    required String name,
    required String validCheckInTime,
    required String validCheckOutTime,
    required bool isActive,
  });

  Future<void> updateWorkTime({
    required String id,
    required String name,
    required String validCheckInTime,
    required String validCheckOutTime,
    required bool isActive,
  });

  Future<void> deleteWorkTime(String id);

  Future<AppWorkTime?> getWorkTimeById(String id);

  Future<List<AppWorkTime>> getPageWorkTime({
    int pageIndex = 1,
    int pageSize = 20,
    String? name,
    bool? isActive,
  });
}
