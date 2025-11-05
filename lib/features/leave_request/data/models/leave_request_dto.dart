import 'package:attendance_system/features/leave_request/domain/entities/leave_request.dart';

class LeaveRequestDto extends AppLeaveRequest {
  LeaveRequestDto({
    required super.id,
    required super.employeeId,
    required super.startDate,
    required super.endDate,
    required super.reason,
    required super.status,
    required super.approvedById,
  });

  factory LeaveRequestDto.fromJson(Map<String, dynamic> json) {
    return LeaveRequestDto(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reason: json['reason'] as String,
      status: _statusFromDynamic(json['status']),
      approvedById: json['approvedById'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status.index,
      'approvedById': approvedById,
    };
  }

  static LeaveStatus _statusFromDynamic(dynamic value) {
    if (value == null) return LeaveStatus.pending;

    // Handle int values
    if (value is int) {
      switch (value) {
        case 0:
          return LeaveStatus.pending;
        case 1:
          return LeaveStatus.approved;
        case 2:
          return LeaveStatus.rejected;
        default:
          return LeaveStatus.pending;
      }
    }

    // Handle String values
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'pending':
          return LeaveStatus.pending;
        case 'approved':
          return LeaveStatus.approved;
        case 'rejected':
          return LeaveStatus.rejected;
        default:
          return LeaveStatus.pending;
      }
    }

    return LeaveStatus.pending;
  }
}
