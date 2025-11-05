import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

class UpdateEmployeeCommand {
  final String id;
  final String code;
  final String fullName;
  final String email;
  final Gender gender;
  final String departmentId;
  final EmployeeStatus status;
  final String? managerId;

  UpdateEmployeeCommand({
    required this.id,
    required this.code,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.departmentId,
    required this.status,
    this.managerId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'fullName': fullName,
    'email': email,
    'gender': gender.index,
    'departmentId': departmentId,
    'status': status.index,
    'managerId': managerId,
  };
}
