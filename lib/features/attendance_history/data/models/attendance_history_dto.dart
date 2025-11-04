import 'package:attendance_system/features/attendance_history/domain/entities/attendance_history.dart';

class AttendanceHistoryDto extends AppAttendanceHistory {
  AttendanceHistoryDto({
    required super.id,
    required super.employeeId,
    required super.attendanceDate,
    required super.type,
    required super.status,
    required super.workTimeId,
  });

  factory AttendanceHistoryDto.fromJson(Map<String, dynamic> json) {
    // Be tolerant: backend may return ints for ids or enums, or timestamps for dates.
    final rawId = json['id'];
    final rawEmployeeId = json['employeeId'];
    final rawDate = json['attendanceDate'];
    final rawType = json['type'];
    final rawStatus = json['status'];
    final rawWorkTimeId = json['workTimeId'];

    final id = rawId == null ? '' : rawId.toString();
    final employeeId = rawEmployeeId == null ? '' : rawEmployeeId.toString();
    final workTimeId = rawWorkTimeId == null ? '' : rawWorkTimeId.toString();

    DateTime attendanceDate;
    if (rawDate is int) {
      // assume epoch millis
      attendanceDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else if (rawDate is String) {
      attendanceDate = DateTime.parse(rawDate);
    } else {
      // fallback to now
      attendanceDate = DateTime.now();
    }

    final type = _typeFromDynamic(rawType);
    final status = _statusFromDynamic(rawStatus);

    return AttendanceHistoryDto(
      id: id,
      employeeId: employeeId,
      attendanceDate: attendanceDate,
      type: type,
      status: status,
      workTimeId: workTimeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'attendanceDate': attendanceDate.toIso8601String(),
      'type': type.index,
      'status': status.index,
      'workTimeId': workTimeId,
    };
  }

  static AttendanceType _typeFromDynamic(dynamic v) {
    if (v == null) return AttendanceType.checkIn;
    if (v is int) {
      return v == 1 ? AttendanceType.checkOut : AttendanceType.checkIn;
    }
    if (v is String) {
      final s = v.toLowerCase();
      switch (s) {
        case 'checkin':
        case 'check_in':
        case 'check-in':
          return AttendanceType.checkIn;
        case 'checkout':
        case 'check_out':
        case 'check-out':
          return AttendanceType.checkOut;
        default:
          return AttendanceType.checkIn;
      }
    }
    return AttendanceType.checkIn;
  }

  static AttendanceStatus _statusFromDynamic(dynamic v) {
    if (v == null) return AttendanceStatus.onTime;
    if (v is int) {
      switch (v) {
        case 1:
          return AttendanceStatus.late;
        case 2:
          return AttendanceStatus.early;
        default:
          return AttendanceStatus.onTime;
      }
    }
    if (v is String) {
      final s = v.toLowerCase();
      switch (s) {
        case 'ontime':
        case 'on_time':
        case 'on-time':
          return AttendanceStatus.onTime;
        case 'late':
          return AttendanceStatus.late;
        case 'early':
          return AttendanceStatus.early;
        default:
          return AttendanceStatus.onTime;
      }
    }
    return AttendanceStatus.onTime;
  }
}
