import '../entities/department.dart';

abstract class DepartmentRepository {
  Future<String> createDepartment({
    required String name,
    String? description,
  });

  Future<List<Department>> getDepartments();

  Future<void> updateDepartment({
    required String id,
    required String name,
    String? description,
  });

  Future<void> deleteDepartment(String id);
}
