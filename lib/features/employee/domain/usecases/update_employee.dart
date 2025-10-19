import '../repositories/employee_repository.dart';

class UpdateEmployee {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  Future<void> call({
    required String id,
    required String fullName,
    required String code,
    int? gender,
    DateTime? birthDate,
    String? departmentId,
    String? titleId,
  }) async {
    return await repository.updateEmployee(
      id: id,
      fullName: fullName,
      code: code,
      gender: gender,
      birthDate: birthDate,
      departmentId: departmentId,
      titleId: titleId,
    );
  }
}
