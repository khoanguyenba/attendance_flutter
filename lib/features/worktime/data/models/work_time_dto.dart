import 'package:attendance_system/features/worktime/domain/entities/app_work_time.dart';

class WorkTimeDto extends AppWorkTime {
  WorkTimeDto({
    required super.id,
    required super.name,
    required super.validCheckInTime,
    required super.validCheckOutTime,
    required super.isActive,
  });

  factory WorkTimeDto.fromJson(Map<String, dynamic> json) {
    return WorkTimeDto(
      id: json['id'] as String,
      name: json['name'] as String,
      validCheckInTime: json['validCheckInTime'] as String,
      validCheckOutTime: json['validCheckOutTime'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'validCheckInTime': validCheckInTime,
      'validCheckOutTime': validCheckOutTime,
      'isActive': isActive,
    };
  }
}
