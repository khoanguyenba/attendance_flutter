import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/core/data/models/common.dart';
import 'package:attendance_system/features/user/data/models/app_user_dto.dart';
import 'package:attendance_system/features/user/data/models/assign_role_command.dart';
import 'package:attendance_system/features/user/data/models/create_user_command.dart';
import 'package:attendance_system/features/user/data/models/login_command.dart';

abstract class UserRemoteDataSource {
  Future<void> login(LoginCommand command);
  Future<void> createUser(CreateUserCommand command);
  Future<void> logout();
  Future<AppUserDto?> getCurrentUser();
  Future<void> assignRole(AssignRoleCommand command);
}

class UserRemoteDataSourceImpl extends BaseRemoteDataSource
    implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(super.dio, super.secureStorage);

  @override
  Future<void> login(LoginCommand command) async {
    var response = await dio.post(
      '/api/users/login',
      data: {'username': command.userName, 'password': command.password},
    );
    if (response.statusCode != 200) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Login failed',
      );
    }
    await saveToken(response.data['token']);
  }

  @override
  Future<void> createUser(CreateUserCommand command) async {
    var response = await dio.post(
      '/api/users/register',
      data: {
        'username': command.userName,
        'password': command.password,
        'employeeId': command.employeeId,
      },
    );
    if (response.statusCode != 201) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Create user failed',
      );
    }
  }

  @override
  Future<void> logout() async {
    await clearToken();
  }

  @override
  Future<AppUserDto?> getCurrentUser() async {
    var response = await dio.get('/api/users/me');
    if (response.statusCode == 200) {
      return AppUserDto.fromJson(response.data);
    }
    if (response.statusCode == 404) {
      return null;
    }
    throw ErrorDataException(
      message: response.data['message'] ?? 'Failed to get current user',
    );
  }

  @override
  Future<void> assignRole(AssignRoleCommand command) async {
    var response = await dio.post(
      '/api/users/${command.userId}/assign-role',
      data: {'role': command.role},
    );
    if (response.statusCode != 204) {
      throw ErrorDataException(
        message: response.data['message'] ?? 'Failed to assign role',
      );
    }
  }
}
