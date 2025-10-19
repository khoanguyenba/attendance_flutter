import '../repositories/attendance_wifi_repository.dart';

class CreateAttendanceWiFi {
  final AttendanceWiFiRepository repository;

  CreateAttendanceWiFi(this.repository);

  Future<String> call({
    required String location,
    required String ssid,
    required String bssid,
    String? description,
  }) async {
    return await repository.createAttendanceWiFi(
      location: location,
      ssid: ssid,
      bssid: bssid,
      description: description,
    );
  }
}
