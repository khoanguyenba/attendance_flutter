import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

class CreateEmployeeCommand {
  final String code;
  final String fullName;
  final String email;
  final Gender gender;
  final String departmentId;
  final EmployeeStatus status;
  final String? managerId;

  CreateEmployeeCommand({
    required this.code,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.departmentId,
    this.status = EmployeeStatus.active,
    this.managerId,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'fullName': fullName,
    'email': email,
    'gender': gender.name,
    'departmentId': departmentId,
    'status': status.name,
    'managerId': managerId,
  };
}
