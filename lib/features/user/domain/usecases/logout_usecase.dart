import 'package:attendance_system/features/user/domain/repositories/app_user_repository.dart';

class LogoutUsecase {
  final AppUserRepository repository;

  LogoutUsecase(this.repository);

  Future<void> call() async {
    await repository.logout();
  }
}
