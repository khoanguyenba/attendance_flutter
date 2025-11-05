import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';

class DeleteLeaveRequestUseCase {
  final AppLeaveRequestRepository repository;

  DeleteLeaveRequestUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteLeaveRequest(id);
  }
}
