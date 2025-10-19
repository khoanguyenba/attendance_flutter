import 'package:attendance_system/features/auth/domain/entities/app_user.dart';

class UserModel extends AppUser {
  UserModel({required super.id, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }

  factory UserModel.fromEntity(AppUser user) {
    return UserModel(id: user.id, email: user.email);
  }

  AppUser toEntity() {
    return AppUser(id: id, email: email);
  }
}
