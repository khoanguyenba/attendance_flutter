import 'package:attendance_system/features/user/domain/repositories/app_user_repository.dart';

class CreateUserUseCase {
  final AppUserRepository repository;

  CreateUserUseCase(this.repository);

  Future<void> call(String userName, String password, String employeeId) async {
    await repository.createUser(userName, password, employeeId);
  }
}
