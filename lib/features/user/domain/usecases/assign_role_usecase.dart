import 'package:attendance_system/features/user/domain/repositories/app_user_repository.dart';

class AssignRoleUseCase {
  final AppUserRepository repository;

  AssignRoleUseCase(this.repository);

  Future<void> call(String userId, String role) async {
    await repository.assignRole(userId, role);
  }
}
