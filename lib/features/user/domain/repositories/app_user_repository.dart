import 'package:attendance_system/features/user/domain/entities/app_user.dart';

abstract class AppUserRepository {
  Future<void> login(String userName, String password);
  Future<void> createUser(String userName, String password, String employeeId);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<void> assignRole(String userId, String role);
}
