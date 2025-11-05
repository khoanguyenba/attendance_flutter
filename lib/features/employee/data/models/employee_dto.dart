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
    super.userId,
  });

  factory EmployeeDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawCode = json['code'];
    final rawFullName = json['fullName'];
    final rawEmail = json['email'];
    final rawGender = json['gender'];
    final rawDepartmentId = json['departmentId'];
    final rawStatus = json['status'];
    final rawManagerId = json['managerId'];
    final rawUserId = json['userId'];

    return EmployeeDto(
      id: rawId == null ? '' : rawId.toString(),
      code: rawCode == null ? '' : rawCode.toString(),
      fullName: rawFullName == null ? '' : rawFullName.toString(),
      email: rawEmail == null ? '' : rawEmail.toString(),
      gender: _genderFromDynamic(rawGender),
      departmentId: rawDepartmentId == null ? '' : rawDepartmentId.toString(),
      status: _statusFromDynamic(rawStatus),
      managerId: rawManagerId?.toString(),
      userId: rawUserId?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  static Gender _genderFromDynamic(dynamic value) {
    if (value == null) {
      throw Exception('Gender is required');
    }
    if (value is int) {
      switch (value) {
        case 0:
          return Gender.male;
        case 1:
          return Gender.female;
        default:
          throw Exception('Gender is invalid');
      }
    }
    if (value is String) {
      final v = value.toLowerCase();
      switch (v) {
        case 'male':
        case 'm':
          return Gender.male;
        case 'female':
        case 'f':
          return Gender.female;
        default:
          throw Exception('Gender is invalid');
      }
    }
    throw Exception('Gender is invalid');
  }

  static EmployeeStatus _statusFromDynamic(dynamic value) {
    if (value == null) return EmployeeStatus.active;
    if (value is int) {
      switch (value) {
        case 1:
          return EmployeeStatus.inactive;
        case 2:
          return EmployeeStatus.suspended;
        default:
          return EmployeeStatus.active;
      }
    }
    if (value is String) {
      final v = value.toLowerCase();
      switch (v) {
        case 'active':
          return EmployeeStatus.active;
        case 'inactive':
          return EmployeeStatus.inactive;
        case 'terminated':
          return EmployeeStatus.suspended;
        default:
          return EmployeeStatus.active;
      }
    }
    return EmployeeStatus.active;
  }
}
