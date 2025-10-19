import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<AttendanceResponse> checkIn({
    required String employeeId,
    required String ssid,
    required String bssid,
  });

  Future<AttendanceResponse> checkOut({
    required String employeeId,
    required String ssid,
    required String bssid,
  });

  Future<List<Attendance>> getAttendanceHistory({
    String? employeeId,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? day,
    int? year,
    int? month,
    String? location,
  });
}
