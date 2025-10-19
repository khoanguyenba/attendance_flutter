import '../repositories/department_repository.dart';

class DeleteDepartment {
  final DepartmentRepository repository;

  DeleteDepartment(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteDepartment(id);
  }
}
