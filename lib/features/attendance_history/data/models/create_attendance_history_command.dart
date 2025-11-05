import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class CreateAttendanceHistoryCommand {
  final AttendanceType type;
  final AttendanceStatus status;
  final String workTimeId;

  CreateAttendanceHistoryCommand({
    required this.type,
    required this.status,
    required this.workTimeId,
  });

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'status': status.index,
    'workTimeId': workTimeId,
  };
}
