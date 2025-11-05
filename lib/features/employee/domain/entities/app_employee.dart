class AppEmployee {
  final String id;
  final String code;
  final String fullName;
  final String email;
  final Gender gender;
  final String departmentId;
  final EmployeeStatus status;
  final String? managerId;

  AppEmployee({
    required this.id,
    required this.code,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.departmentId,
    required this.status,
    this.managerId,
  });
}

enum Gender { male, female, other }

enum EmployeeStatus { active, inactive, terminated }
