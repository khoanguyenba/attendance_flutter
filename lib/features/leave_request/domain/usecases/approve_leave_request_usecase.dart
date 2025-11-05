import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';

class ApproveLeaveRequestUseCase {
  final AppLeaveRequestRepository repository;

  ApproveLeaveRequestUseCase(this.repository);

  Future<void> call(String id, String approverId) async {
    await repository.approveLeaveRequest(id, approverId);
  }
}
