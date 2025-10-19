import '../entities/attendance_wifi.dart';
import '../repositories/attendance_wifi_repository.dart';

class GetAttendanceWiFis {
  final AttendanceWiFiRepository repository;

  GetAttendanceWiFis(this.repository);

  Future<List<AttendanceWiFi>> call() async {
    return await repository.getAttendanceWiFis();
  }
}
