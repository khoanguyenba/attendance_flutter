class AppLeaveRequest {
  final String id;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String? approvedById;

  AppLeaveRequest({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedById,
  });
}

enum LeaveStatus { pending, approved, rejected }
