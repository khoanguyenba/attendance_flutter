import 'package:attendance_system/core/usecase/usecase.dart';
import 'package:attendance_system/features/auth/domain/entities/app_user.dart';
import 'package:attendance_system/features/auth/domain/repositories/user_repository.dart';

class GetCurrentUser extends UseCase<AppUser?, void> {
  final UserRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<AppUser?> call(void params) {
    return repository.getCurrentUser();
  }
}
