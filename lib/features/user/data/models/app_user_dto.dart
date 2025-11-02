import 'package:attendance_system/features/user/domain/entities/app_user.dart';

class AppUserDto extends AppUser {
  AppUserDto({
    required super.id,
    required super.userName,
    required super.email,
    required super.role,
  });

  factory AppUserDto.fromJson(Map<String, dynamic> json) {
    return AppUserDto(
      id: json['id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userName': userName, 'email': email, 'role': role};
  }

  AppUser toEntity() {
    return AppUser(id: id, userName: userName, email: email, role: role);
  }
}
