class AppAttendanceHistory {
  final String id;
  final String employeeId;
  final DateTime attendanceDate;
  final AttendanceType type;
  final AttendanceStatus status;

  AppAttendanceHistory({
    required this.id,
    required this.employeeId,
    required this.attendanceDate,
    required this.type,
    required this.status,
  });
}

enum AttendanceType { checkIn, checkOut }

enum AttendanceStatus { onTime, late, early }
