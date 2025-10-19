import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeBasicInfo {
  final EmployeeRepository repository;

  GetEmployeeBasicInfo(this.repository);

  Future<List<EmployeeBasicInfo>> call() async {
    return await repository.getEmployeeBasicInfo();
  }
}
