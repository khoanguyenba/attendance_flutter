import 'package:attendance_system/features/user/domain/repositories/app_user_repository.dart';

class LoginUseCase {
  final AppUserRepository repository;

  LoginUseCase(this.repository);

  Future<void> call(String userName, String password) async {
    await repository.login(userName, password);
  }
}
