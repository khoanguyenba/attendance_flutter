import 'package:attendance_system/features/auth/data/datasources/user_remote_datasource.dart';
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
  Future<AppUser?> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
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
  Future<AppUser?> register(String email, String password) async {
    final userModel = await remoteDataSource.register(email, password);
    if (userModel != null) {
      return userModel.toEntity();
    }
    return null;
  }
}
