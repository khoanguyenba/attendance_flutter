import '../entities/department.dart';
import '../repositories/department_repository.dart';

class GetDepartments {
  final DepartmentRepository repository;

  GetDepartments(this.repository);

  Future<List<Department>> call() async {
    return await repository.getDepartments();
  }
}
