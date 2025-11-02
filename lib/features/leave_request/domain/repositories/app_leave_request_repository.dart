import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';

abstract class AppLeaveRequestRepository {
  Future<AppLeaveRequest> createLeaveRequest({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required String approvedById,
  });
  Future<void> deleteLeaveRequest(String id);

  Future<AppLeaveRequest?> getLeaveRequestById(String id);

  Future<List<AppLeaveRequest>> getPageLeaveRequest({
    int pageIndex = 1,
    int pageSize = 20,
    String? employeeId,
    LeaveStatus? status,
  });
}
