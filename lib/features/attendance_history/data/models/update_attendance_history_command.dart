import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class UpdateAttendanceHistoryCommand {
  final String id;
  final String employeeId;
  final DateTime attendanceDate;
  final AttendanceType type;
  final AttendanceStatus status;

  UpdateAttendanceHistoryCommand({
    required this.id,
    required this.employeeId,
    required this.attendanceDate,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'attendanceDate': attendanceDate.toIso8601String(),
    'type': type.name,
    'status': status.name,
  };
}
