import 'package:attendance_system/features/auth/domain/entities/app_user.dart';

class AppUserDto extends AppUser {
  AppUserDto({
    required super.id,
    required super.email,
    required super.userName,
    super.role,
  });

  factory AppUserDto.fromJson(Map<String, dynamic> json) {
    return AppUserDto(
      id: json['id'],
      email: json['email'],
      userName: json['userName'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'userName': userName, 'role': role};
  }

  AppUser toEntity() {
    return AppUser(id: id, email: email, userName: userName, role: role);
  }
}

class LoginCommand {
  final String username;
  final String password;

  LoginCommand({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class LoginCommandResponse {
  final String token;
  final DateTime expiration;

  LoginCommandResponse({required this.token, required this.expiration});

  factory LoginCommandResponse.fromJson(Map<String, dynamic> json) {
    return LoginCommandResponse(
      token: json['token'],
      expiration: DateTime.parse(json['expiration']),
    );
  }
}

class CreateUserCommand {
  final String userName;
  final String password;
  final String employeeId;

  CreateUserCommand({
    required this.userName,
    required this.password,
    required this.employeeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
      'employeeId': employeeId,
    };
  }
}

class AssignRoleCommand {
  final String userId;
  final String role;

  AssignRoleCommand({required this.userId, required this.role});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'role': role};
  }
}
