import 'package:attendance_system/features/auth/domain/entities/app_user.dart';

abstract class UserRepository {
  Future<AppUser?> login(String email, String password);
  Future<AppUser?> register(String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
