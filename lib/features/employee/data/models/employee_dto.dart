import 'package:attendance_system/features/employee/domain/entities/app_employee.dart';

class EmployeeDto extends AppEmployee {
  EmployeeDto({
    required super.id,
    required super.code,
    required super.fullName,
    required super.email,
    required super.gender,
    required super.departmentId,
    required super.status,
    super.managerId,
  });

  factory EmployeeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDto(
      id: json['id'] as String,
      code: json['code'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      gender: _genderFromString(json['gender'] as String?),
      departmentId: json['departmentId'] as String,
      status: _statusFromString(json['status'] as String?),
      managerId: json['managerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'fullName': fullName,
      'email': email,
      'gender': gender.name,
      'departmentId': departmentId,
      'status': status.name,
      'managerId': managerId,
    };
  }

  static Gender _genderFromString(String? value) {
    if (value == null) return Gender.other;
    switch (value.toLowerCase()) {
      case 'male':
      case 'm':
        return Gender.male;
      case 'female':
      case 'f':
        return Gender.female;
      default:
        return Gender.other;
    }
  }

  static EmployeeStatus _statusFromString(String? value) {
    if (value == null) return EmployeeStatus.active;
    switch (value.toLowerCase()) {
      case 'active':
        return EmployeeStatus.active;
      case 'inactive':
        return EmployeeStatus.inactive;
      case 'terminated':
        return EmployeeStatus.terminated;
      default:
        return EmployeeStatus.active;
    }
  }
}
