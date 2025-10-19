import '../entities/employee.dart';
import '../repositories/employee_repository.dart';
import '../../../../core/usecase/usecase.dart';

class GetEmployeesParams {
  final int pageNumber;
  final int pageSize;
  final String? code;
  final String? fullName;
  final String? departmentId;
  final String? titleId;

  GetEmployeesParams({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.code,
    this.fullName,
    this.departmentId,
    this.titleId,
  });
}

class GetEmployees implements UseCase<List<Employee>, GetEmployeesParams> {
  final EmployeeRepository repository;

  GetEmployees(this.repository);

  @override
  Future<List<Employee>> call(GetEmployeesParams params) async {
    return await repository.getEmployees(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      code: params.code,
      fullName: params.fullName,
      departmentId: params.departmentId,
      titleId: params.titleId,
    );
  }
}
