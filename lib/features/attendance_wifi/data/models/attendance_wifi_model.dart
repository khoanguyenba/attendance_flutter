import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_wifi.dart';

class AttendanceWiFiModel extends AttendanceWiFi {
  const AttendanceWiFiModel({
    required super.id,
    required super.location,
    required super.ssid,
    required super.bssid,
    super.description,
    required super.createdAt,
  });

  factory AttendanceWiFiModel.fromJson(Map<String, dynamic> json) {
    return AttendanceWiFiModel(
      id: json['id'] as String,
      location: json['location'] as String,
      ssid: json['ssid'] as String,
      bssid: json['bssid'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  factory AttendanceWiFiModel.fromListJson(Map<String, dynamic> json) {
    return AttendanceWiFiModel(
      id: json['id'] as String,
      location: json['location'] as String,
      ssid: json['ssid'] as String,
      bssid: json['bssid'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'ssid': ssid,
      'bssid': bssid,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AttendanceWiFiModel.fromCreateJson(Map<String, dynamic> json) {
    return AttendanceWiFiModel(
      id: json['id'] as String,
      location: '',
      ssid: '',
      bssid: '',
      createdAt: DateTime.now(),
    );
  }
}
