import '../repositories/attendance_wifi_repository.dart';

class UpdateAttendanceWiFi {
  final AttendanceWiFiRepository repository;

  UpdateAttendanceWiFi(this.repository);

  Future<void> call({
    required String id,
    required String location,
    required String ssid,
    required String bssid,
    String? description,
  }) async {
    return await repository.updateAttendanceWiFi(
      id: id,
      location: location,
      ssid: ssid,
      bssid: bssid,
      description: description,
    );
  }
}
