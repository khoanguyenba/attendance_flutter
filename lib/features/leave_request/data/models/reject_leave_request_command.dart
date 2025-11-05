class RejectLeaveRequestCommand {
  final String leaveRequestId;
  final String rejectedById;

  RejectLeaveRequestCommand({
    required this.leaveRequestId,
    required this.rejectedById,
  });

  Map<String, dynamic> toJson() => {
    'leaveRequestId': leaveRequestId,
    'rejectedById': rejectedById,
  };
}
