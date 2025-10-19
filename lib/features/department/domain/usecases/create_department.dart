import '../repositories/department_repository.dart';

class CreateDepartment {
  final DepartmentRepository repository;

  CreateDepartment(this.repository);

  Future<String> call({
    required String name,
    String? description,
  }) async {
    return await repository.createDepartment(
      name: name,
      description: description,
    );
  }
}
