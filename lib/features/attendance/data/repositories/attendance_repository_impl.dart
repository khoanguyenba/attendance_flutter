import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AttendanceResponse> checkIn({
    required String employeeId,
    required String ssid,
    required String bssid,
  }) async {
    final data = {
      'employeeId': employeeId,
      'ssid': ssid,
      'bssid': bssid,
    };

    return await remoteDataSource.checkIn(data);
  }

  @override
  Future<AttendanceResponse> checkOut({
    required String employeeId,
    required String ssid,
    required String bssid,
  }) async {
    final data = {
      'employeeId': employeeId,
      'ssid': ssid,
      'bssid': bssid,
    };

    return await remoteDataSource.checkOut(data);
  }

  @override
  Future<List<Attendance>> getAttendanceHistory({
    String? employeeId,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? day,
    int? year,
    int? month,
    String? location,
  }) async {
    final params = <String, dynamic>{};
    
    if (employeeId != null) params['EmployeeId'] = employeeId;
    if (fromDate != null) params['FromDate'] = fromDate.toIso8601String();
    if (toDate != null) params['ToDate'] = toDate.toIso8601String();
    if (day != null) params['Day'] = day.toIso8601String();
    if (year != null) params['Year'] = year;
    if (month != null) params['Month'] = month;
    if (location != null) params['Location'] = location;

    return await remoteDataSource.getAttendanceHistory(params);
  }
}
