import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';
import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';

class GetPageLeaveRequestUseCase {
  final AppLeaveRequestRepository repository;

  GetPageLeaveRequestUseCase(this.repository);

  Future<List<AppLeaveRequest>> call({
    int pageIndex = 1,
    int pageSize = 20,
    String? employeeId,
    LeaveStatus? status,
  }) async {
    return await repository.getPageLeaveRequest(
      pageIndex: pageIndex,
      pageSize: pageSize,
      employeeId: employeeId,
      status: status,
    );
  }
}
