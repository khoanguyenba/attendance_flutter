class CreateLeaveRequestCommand {
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  CreateLeaveRequestCommand({
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'reason': reason,
  };
}
