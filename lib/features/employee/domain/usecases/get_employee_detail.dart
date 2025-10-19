import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeDetail {
  final EmployeeRepository repository;

  GetEmployeeDetail(this.repository);

  Future<Employee> call(String id) async {
    return await repository.getEmployeeDetail(id);
  }
}
