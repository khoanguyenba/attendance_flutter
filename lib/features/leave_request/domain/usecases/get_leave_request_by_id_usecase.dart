import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';
import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';

class GetLeaveRequestByIdUseCase {
  final AppLeaveRequestRepository repository;

  GetLeaveRequestByIdUseCase(this.repository);

  Future<AppLeaveRequest?> call(String id) async {
    return await repository.getLeaveRequestById(id);
  }
}
