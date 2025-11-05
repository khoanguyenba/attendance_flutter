import 'package:attendance_system/features/employee/domain/repositories/app_employee_repository.dart';
import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

class GetEmployeeByIdUseCase {
  final AppEmployeeRepository repository;

  GetEmployeeByIdUseCase(this.repository);

  Future<AppEmployee?> call(String id) async {
    return await repository.getEmployeeById(id);
  }
}
