import 'package:attendance_system/features/leave_request/data/datasources/leave_request_remote_datasource.dart';
import 'package:attendance_system/features/leave_request/data/models/create_leave_request_command.dart';
import 'package:attendance_system/features/leave_request/data/models/delete_leave_request_command.dart';
import 'package:attendance_system/features/leave_request/data/models/get_page_leave_request_query.dart';
import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';
import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';

class AppLeaveRequestRepositoryImpl implements AppLeaveRequestRepository {
  final LeaveRequestRemoteDataSource remoteDataSource;

  AppLeaveRequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppLeaveRequest> createLeaveRequest({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required String approvedById,
  }) async {
    final command = CreateLeaveRequestCommand(
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      approvedById: approvedById,
    );
    final dto = await remoteDataSource.createLeaveRequest(command);
    return AppLeaveRequest(
      id: dto.id,
      employeeId: dto.employeeId,
      startDate: dto.startDate,
      endDate: dto.endDate,
      reason: dto.reason,
      status: dto.status,
      approvedById: dto.approvedById,
    );
  }

  // Update is not supported by API; removed.

  @override
  Future<void> deleteLeaveRequest(String id) async {
    await remoteDataSource.deleteLeaveRequest(DeleteLeaveRequestCommand(id));
  }

  @override
  Future<AppLeaveRequest?> getLeaveRequestById(String id) async {
    final dto = await remoteDataSource.getLeaveRequestById(id);
    if (dto == null) return null;
    return AppLeaveRequest(
      id: dto.id,
      employeeId: dto.employeeId,
      startDate: dto.startDate,
      endDate: dto.endDate,
      reason: dto.reason,
      status: dto.status,
      approvedById: dto.approvedById,
    );
  }

  @override
  Future<List<AppLeaveRequest>> getPageLeaveRequest({
    int pageIndex = 1,
    int pageSize = 20,
    String? employeeId,
    LeaveStatus? status,
  }) async {
    final query = GetPageLeaveRequestQuery(
      pageIndex: pageIndex,
      pageSize: pageSize,
      employeeId: employeeId,
      status: status,
    );
    final dtos = await remoteDataSource.getPageLeaveRequest(query);
    return dtos
        .map(
          (dto) => AppLeaveRequest(
            id: dto.id,
            employeeId: dto.employeeId,
            startDate: dto.startDate,
            endDate: dto.endDate,
            reason: dto.reason,
            status: dto.status,
            approvedById: dto.approvedById,
          ),
        )
        .toList();
  }
}
