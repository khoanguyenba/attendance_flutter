import 'package:attendance_system/features/user/data/datasources/user_remote_datasource.dart';
import 'package:attendance_system/features/user/data/models/assign_role_command.dart';
import 'package:attendance_system/features/user/data/models/create_user_command.dart';
import 'package:attendance_system/features/user/data/models/login_command.dart';
import 'package:attendance_system/features/user/domain/entities/app_user.dart';
import 'package:attendance_system/features/user/domain/repositories/app_user_repository.dart';

class AppUserRepositoryImpl implements AppUserRepository {
  final UserRemoteDataSource remoteDataSource;

  AppUserRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> assignRole(String userId, String role) async {
    return await remoteDataSource.assignRole(
      AssignRoleCommand(userId: userId, role: role),
    );
  }

  @override
  Future<void> createUser(
    String userName,
    String password,
    String employeeId,
  ) async {
    return await remoteDataSource.createUser(
      CreateUserCommand(
        userName: userName,
        password: password,
        employeeId: employeeId,
      ),
    );
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    var dto = await remoteDataSource.getCurrentUser();
    return dto?.toEntity();
  }

  @override
  Future<void> login(String userName, String password) async {
    return await remoteDataSource.login(
      LoginCommand(userName: userName, password: password),
    );
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }
}
