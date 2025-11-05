class CreateLeaveRequestCommand {
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String approvedById;

  CreateLeaveRequestCommand({
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.approvedById,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'reason': reason,
    'approvedById': approvedById,
  };
}
