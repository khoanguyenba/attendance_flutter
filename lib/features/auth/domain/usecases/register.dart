import 'package:attendance_system/core/usecase/usecase.dart';
import 'package:attendance_system/features/auth/domain/entities/app_user.dart';
import 'package:attendance_system/features/auth/domain/repositories/user_repository.dart';

class Register extends UseCase<AppUser?, RegisterParams> {
  final UserRepository repository;

  Register(this.repository);

  @override
  Future<AppUser?> call(RegisterParams params) {
    return repository.register(params.email, params.password);
  }
}

class RegisterParams {
  final String email;
  final String password;

  RegisterParams({required this.email, required this.password});
}
