import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';
import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';

class CreateLeaveRequestUseCase {
  final AppLeaveRequestRepository repository;

  CreateLeaveRequestUseCase(this.repository);

  Future<AppLeaveRequest> call({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    return await repository.createLeaveRequest(
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }
}
