import 'package:attendance_system/core/usecase/usecase.dart';
import 'package:attendance_system/features/auth/domain/repositories/user_repository.dart';

class Logout extends UseCase<void, void> {
  final UserRepository repository;

  Logout(this.repository);

  @override
  Future<void> call(void params) {
    return repository.logout();
  }
}
