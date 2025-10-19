class Attendance {
  final String id;
  final String employeeId;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int? checkInStatus;
  final int? checkOutStatus;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
    this.checkInStatus,
    this.checkOutStatus,
  });

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? createdAt,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    int? checkInStatus,
    int? checkOutStatus,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      checkOutStatus: checkOutStatus ?? this.checkOutStatus,
    );
  }
}

class AttendanceResponse {
  final String id;
  final String message;
  final DateTime timestamp;

  const AttendanceResponse({
    required this.id,
    required this.message,
    required this.timestamp,
  });
}

enum AttendanceStatus {
  onTime(0),
  late(1),
  early(2);

  const AttendanceStatus(this.value);
  final int value;

  static AttendanceStatus fromValue(int value) {
    switch (value) {
      case 0:
        return AttendanceStatus.onTime;
      case 1:
        return AttendanceStatus.late;
      case 2:
        return AttendanceStatus.early;
      default:
        return AttendanceStatus.onTime;
    }
  }

  String get displayName {
    switch (this) {
      case AttendanceStatus.onTime:
        return 'Đúng giờ';
      case AttendanceStatus.late:
        return 'Muộn';
      case AttendanceStatus.early:
        return 'Sớm';
    }
  }
}
