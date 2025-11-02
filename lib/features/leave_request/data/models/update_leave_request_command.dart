import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';

class UpdateLeaveRequestCommand {
  final String id;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String approvedById;

  UpdateLeaveRequestCommand({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.approvedById,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'reason': reason,
    'status': status.name,
    'approvedById': approvedById,
  };
}
