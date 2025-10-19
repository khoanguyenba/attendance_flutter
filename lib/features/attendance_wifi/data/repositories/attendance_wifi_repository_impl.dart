import '../../domain/entities/attendance_wifi.dart';
import '../../domain/repositories/attendance_wifi_repository.dart';
import '../datasources/attendance_wifi_remote_datasource.dart';

class AttendanceWiFiRepositoryImpl implements AttendanceWiFiRepository {
  final AttendanceWiFiRemoteDataSource remoteDataSource;

  AttendanceWiFiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createAttendanceWiFi({
    required String location,
    required String ssid,
    required String bssid,
    String? description,
  }) async {
    final data = {
      'location': location,
      'ssid': ssid,
      'bssid': bssid,
      if (description != null) 'description': description,
    };

    return await remoteDataSource.createAttendanceWiFi(data);
  }

  @override
  Future<List<AttendanceWiFi>> getAttendanceWiFis() async {
    return await remoteDataSource.getAttendanceWiFis();
  }

  @override
  Future<AttendanceWiFi> getAttendanceWiFiDetail(String id) async {
    return await remoteDataSource.getAttendanceWiFiDetail(id);
  }

  @override
  Future<void> updateAttendanceWiFi({
    required String id,
    required String location,
    required String ssid,
    required String bssid,
    String? description,
  }) async {
    final data = {
      'id': id,
      'location': location,
      'ssid': ssid,
      'bssid': bssid,
      if (description != null) 'description': description,
    };

    await remoteDataSource.updateAttendanceWiFi(id, data);
  }

  @override
  Future<void> deleteAttendanceWiFi(String id) async {
    await remoteDataSource.deleteAttendanceWiFi(id);
  }
}
