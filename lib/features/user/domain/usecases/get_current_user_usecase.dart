import 'package:attendance_system/features/user/domain/entities/app_user.dart';
import 'package:attendance_system/features/user/domain/repositories/app_user_repository.dart';

class GetCurrentUserUseCase {
  final AppUserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<AppUser?> call() async {
    return await repository.getCurrentUser();
  }
}
