import 'package:attendance_system/features/user/domain/entities/app_user.dart';

class AppUserDto extends AppUser {
  AppUserDto({
    required super.id,
    required super.userName,
    required super.email,
    required super.role,
    required super.employeeId,
  });

  factory AppUserDto.fromJson(Map<String, dynamic> json) {
    return AppUserDto(
      id: json['id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      employeeId: json['employeeId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'role': role,
      'employeeId': employeeId,
    };
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      userName: userName,
      email: email,
      role: role,
      employeeId: employeeId,
    );
  }
}
