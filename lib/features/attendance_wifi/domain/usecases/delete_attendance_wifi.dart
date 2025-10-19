import '../repositories/attendance_wifi_repository.dart';

class DeleteAttendanceWiFi {
  final AttendanceWiFiRepository repository;

  DeleteAttendanceWiFi(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteAttendanceWiFi(id);
  }
}
