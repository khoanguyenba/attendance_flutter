import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance.dart';

class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    required super.createdAt,
    super.checkInTime,
    super.checkOutTime,
    super.checkInStatus,
    super.checkOutStatus,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      checkInTime: json['checkInTime'] != null 
          ? DateTime.parse(json['checkInTime'] as String)
          : null,
      checkOutTime: json['checkOutTime'] != null 
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      checkInStatus: json['checkInStatus'] as int?,
      checkOutStatus: json['checkOutStatus'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'createdAt': createdAt.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'checkInStatus': checkInStatus,
      'checkOutStatus': checkOutStatus,
    };
  }
}

class AttendanceResponseModel extends AttendanceResponse {
  const AttendanceResponseModel({
    required super.id,
    required super.message,
    required super.timestamp,
  });

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceResponseModel(
      id: json['id'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : json['timestamp'] is String 
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
