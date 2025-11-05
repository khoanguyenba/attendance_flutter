class ApproveLeaveRequestCommand {
  final String leaveRequestId;
  final String approvedById;

  ApproveLeaveRequestCommand({
    required this.leaveRequestId,
    required this.approvedById,
  });

  Map<String, dynamic> toJson() => {
    'leaveRequestId': leaveRequestId,
    'approvedById': approvedById,
  };
}
