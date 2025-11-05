import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';

class RejectLeaveRequestUseCase {
  final AppLeaveRequestRepository repository;

  RejectLeaveRequestUseCase(this.repository);

  Future<void> call(String id, String approverId) async {
    await repository.rejectLeaveRequest(id, approverId);
  }
}
