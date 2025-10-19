import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class CheckIn {
  final AttendanceRepository repository;

  CheckIn(this.repository);

  Future<AttendanceResponse> call({
    required String employeeId,
    required String ssid,
    required String bssid,
  }) async {
    return await repository.checkIn(
      employeeId: employeeId,
      ssid: ssid,
      bssid: bssid,
    );
  }
}
