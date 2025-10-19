import '../../domain/entities/department.dart';
import '../../domain/repositories/department_repository.dart';
import '../datasources/department_remote_datasource.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource remoteDataSource;

  DepartmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createDepartment({
    required String name,
    String? description,
  }) async {
    final data = {
      'name': name,
      if (description != null) 'description': description,
    };

    return await remoteDataSource.createDepartment(data);
  }

  @override
  Future<List<Department>> getDepartments() async {
    return await remoteDataSource.getDepartments();
  }

  @override
  Future<void> updateDepartment({
    required String id,
    required String name,
    String? description,
  }) async {
    final data = {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };

    await remoteDataSource.updateDepartment(id, data);
  }

  @override
  Future<void> deleteDepartment(String id) async {
    await remoteDataSource.deleteDepartment(id);
  }
}
