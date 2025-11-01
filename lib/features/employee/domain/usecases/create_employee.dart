import '../repositories/employee_repository.dart';

class CreateEmployee {
  final EmployeeRepository repository;

  CreateEmployee(this.repository);

  Future<String> call({
    required String fullName,
    required String code,
    required String email,
    int? gender,
    DateTime? birthDate,
    String? departmentId,
    String? titleId,
  }) async {
    return await repository.createEmployee(
      fullName: fullName,
      code: code,
      email: email,
      gender: gender,
      birthDate: birthDate,
      departmentId: departmentId,
      titleId: titleId,
    );
  }
}
