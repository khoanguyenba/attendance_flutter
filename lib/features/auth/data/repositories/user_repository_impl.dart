import 'package:attendance_system/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:attendance_system/features/auth/data/models/user_model.dart';
import 'package:attendance_system/features/auth/domain/entities/app_user.dart';
import 'package:attendance_system/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser?> getCurrentUser() async {
    final userModel = await remoteDataSource.getCurrentUser();
    if (userModel != null) {
      return userModel.toEntity();
    }
    return null;
  }

  @override
  Future<AppUser?> login(String username, String password) async {
    await remoteDataSource.login(
      LoginCommand(username: username, password: password),
    );
    var userModel = await remoteDataSource.getCurrentUser();
    if (userModel != null) {
      return userModel.toEntity();
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<AppUser?> register(
    String username,
    String password,
    String employeeId,
  ) async {
    await remoteDataSource.register(
      CreateUserCommand(
        userName: username,
        password: password,
        employeeId: employeeId,
      ),
    );
    return null;
  }
}
