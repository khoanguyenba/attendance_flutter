import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class CreateAttendanceHistoryCommand {
  final AttendanceType type;
  final AttendanceStatus status;

  CreateAttendanceHistoryCommand({required this.type, required this.status});

  Map<String, dynamic> toJson() => {'type': type.name, 'status': status.name};
}
