import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class AttendanceHistoryDto extends AppAttendanceHistory {
  AttendanceHistoryDto({
    required super.id,
    required super.employeeId,
    required super.attendanceDate,
    required super.type,
    required super.status,
  });

  factory AttendanceHistoryDto.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryDto(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      attendanceDate: DateTime.parse(json['attendanceDate'] as String),
      type: _typeFromString(json['type'] as String?),
      status: _statusFromString(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'attendanceDate': attendanceDate.toIso8601String(),
      'type': type.name,
      'status': status.name,
    };
  }

  static AttendanceType _typeFromString(String? v) {
    if (v == null) return AttendanceType.checkIn;
    switch (v.toLowerCase()) {
      case 'checkin':
      case 'check_in':
      case 'check-in':
        return AttendanceType.checkIn;
      case 'checkout':
      case 'check_out':
      case 'check-out':
        return AttendanceType.checkOut;
      default:
        return AttendanceType.checkIn;
    }
  }

  static AttendanceStatus _statusFromString(String? v) {
    if (v == null) return AttendanceStatus.onTime;
    switch (v.toLowerCase()) {
      case 'ontime':
      case 'on_time':
      case 'on-time':
        return AttendanceStatus.onTime;
      case 'late':
        return AttendanceStatus.late;
      case 'early':
        return AttendanceStatus.early;
      default:
        return AttendanceStatus.onTime;
    }
  }
}
