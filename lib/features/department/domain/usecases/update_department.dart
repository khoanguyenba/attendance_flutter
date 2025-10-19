import '../repositories/department_repository.dart';

class UpdateDepartment {
  final DepartmentRepository repository;

  UpdateDepartment(this.repository);

  Future<void> call({
    required String id,
    required String name,
    String? description,
  }) async {
    return await repository.updateDepartment(
      id: id,
      name: name,
      description: description,
    );
  }
}
