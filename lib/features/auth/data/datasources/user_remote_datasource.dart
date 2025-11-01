import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/core/data/models/common.dart';
import 'package:attendance_system/features/auth/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> login(LoginCommand command);
  Future<void> register(CreateUserCommand command);
  Future<void> logout();
  Future<AppUserDto?> getCurrentUser();
}

class UserRemoteDataSourceImpl extends BaseRemoteDataSource
    implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(super.dio, super.secureStorage);

  @override
  Future<AppUserDto?> getCurrentUser() async {
    var response = await dio.get('/api/user/me');
    if (response.statusCode == 200) {
      return AppUserDto.fromJson(response.data);
    } else {
      var message = response.data['message'] ?? 'Unknown error occurred';
      throw ErrorDataException(message: message);
    }
  }

  @override
  Future<void> login(LoginCommand command) async {
    var response = await dio.post('/api/user/login', data: command.toJson());
    if (response.statusCode == 200) {
      await saveToken(response.data['token']);
    } else {
      var message = response.data['message'] ?? 'Unknown error occurred';
      throw ErrorDataException(message: message);
    }
  }

  @override
  Future<void> logout() async {
    await clearToken();
  }

  @override
  Future<void> register(CreateUserCommand command) async {
    var response = await dio.post('/api/user/register', data: command.toJson());
    if (response.statusCode != 201) {
      var message = response.data['message'] ?? 'Unknown error occurred';
      throw ErrorDataException(message: message);
    }
  }
}
