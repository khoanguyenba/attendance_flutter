import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class CheckOut {
  final AttendanceRepository repository;

  CheckOut(this.repository);

  Future<AttendanceResponse> call({
    required String employeeId,
    required String ssid,
    required String bssid,
  }) async {
    return await repository.checkOut(
      employeeId: employeeId,
      ssid: ssid,
      bssid: bssid,
    );
  }
}
