import '../entities/attendance_wifi.dart';

abstract class AttendanceWiFiRepository {
  Future<String> createAttendanceWiFi({
    required String location,
    required String ssid,
    required String bssid,
    String? description,
  });

  Future<List<AttendanceWiFi>> getAttendanceWiFis();

  Future<AttendanceWiFi> getAttendanceWiFiDetail(String id);

  Future<void> updateAttendanceWiFi({
    required String id,
    required String location,
    required String ssid,
    required String bssid,
    String? description,
  });

  Future<void> deleteAttendanceWiFi(String id);
}
