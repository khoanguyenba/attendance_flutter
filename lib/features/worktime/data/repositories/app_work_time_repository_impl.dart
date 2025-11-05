import 'package:attendance_system/features/worktime/data/datasources/work_time_remote_datasource.dart';
import 'package:attendance_system/features/worktime/data/models/create_work_time_command.dart';
import 'package:attendance_system/features/worktime/data/models/update_work_time_command.dart';
import 'package:attendance_system/features/worktime/data/models/delete_work_time_command.dart';
import 'package:attendance_system/features/worktime/data/models/get_page_work_time_query.dart';
import 'package:attendance_system/features/worktime/domain/entities/app_work_time.dart';
import 'package:attendance_system/features/worktime/domain/repositories/app_work_time_repository.dart';

class AppWorkTimeRepositoryImpl implements AppWorkTimeRepository {
  final WorkTimeRemoteDataSource remoteDataSource;

  AppWorkTimeRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppWorkTime> createWorkTime({
    required String name,
    required String validCheckInTime,
    required String validCheckOutTime,
    required bool isActive,
  }) async {
    final command = CreateWorkTimeCommand(
      name: name,
      validCheckInTime: validCheckInTime,
      validCheckOutTime: validCheckOutTime,
      isActive: isActive,
    );
    final dto = await remoteDataSource.createWorkTime(command);
    return AppWorkTime(
      id: dto.id,
      name: dto.name,
      validCheckInTime: dto.validCheckInTime,
      validCheckOutTime: dto.validCheckOutTime,
      isActive: dto.isActive,
    );
  }

  @override
  Future<void> updateWorkTime({
    required String id,
    required String name,
    required String validCheckInTime,
    required String validCheckOutTime,
    required bool isActive,
  }) async {
    final command = UpdateWorkTimeCommand(
      id: id,
      name: name,
      validCheckInTime: validCheckInTime,
      validCheckOutTime: validCheckOutTime,
      isActive: isActive,
    );
    await remoteDataSource.updateWorkTime(command);
  }

  @override
  Future<void> deleteWorkTime(String id) async {
    await remoteDataSource.deleteWorkTime(DeleteWorkTimeCommand(id));
  }

  @override
  Future<AppWorkTime?> getWorkTimeById(String id) async {
    final dto = await remoteDataSource.getWorkTimeById(id);
    if (dto == null) return null;
    return AppWorkTime(
      id: dto.id,
      name: dto.name,
      validCheckInTime: dto.validCheckInTime,
      validCheckOutTime: dto.validCheckOutTime,
      isActive: dto.isActive,
    );
  }

  @override
  Future<List<AppWorkTime>> getPageWorkTime({
    int pageIndex = 1,
    int pageSize = 20,
    String? name,
    bool? isActive,
  }) async {
    final query = GetPageWorkTimeQuery(
      pageIndex: pageIndex,
      pageSize: pageSize,
      name: name,
      isActive: isActive,
    );
    final dtos = await remoteDataSource.getPageWorkTime(query);
    return dtos
        .map(
          (dto) => AppWorkTime(
            id: dto.id,
            name: dto.name,
            validCheckInTime: dto.validCheckInTime,
            validCheckOutTime: dto.validCheckOutTime,
            isActive: dto.isActive,
          ),
        )
        .toList();
  }
}
