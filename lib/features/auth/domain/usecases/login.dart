import 'package:attendance_system/core/usecase/usecase.dart';
import 'package:attendance_system/features/auth/domain/entities/app_user.dart';
import 'package:attendance_system/features/auth/domain/repositories/user_repository.dart';

class Login extends UseCase<AppUser?, LoginParams> {
  final UserRepository repository;

  Login(this.repository);

  @override
  Future<AppUser?> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
