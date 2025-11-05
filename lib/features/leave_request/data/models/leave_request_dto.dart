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
      status: _statusFromString(json['status'] as String?),
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
      'status': status.name,
      'approvedById': approvedById,
    };
  }

  static LeaveStatus _statusFromString(String? v) {
    if (v == null) return LeaveStatus.pending;
    switch (v.toLowerCase()) {
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
}
