class Employee {
  final String id;
  final String fullName;
  final String code;
  final String email;
  final int? gender;
  final DateTime? birthDate;
  final String? departmentId;
  final String? titleId;
  final DateTime createdAt;
  final String? titleName;
  final String? departmentName;

  const Employee({
    required this.id,
    required this.fullName,
    required this.code,
    required this.email,
    this.gender,
    this.birthDate,
    this.departmentId,
    this.titleId,
    required this.createdAt,
    this.titleName,
    this.departmentName,
  });

  Employee copyWith({
    String? id,
    String? fullName,
    String? code,
    String? email,
    int? gender,
    DateTime? birthDate,
    String? departmentId,
    String? titleId,
    DateTime? createdAt,
    String? titleName,
    String? departmentName,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      code: code ?? this.code,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      departmentId: departmentId ?? this.departmentId,
      titleId: titleId ?? this.titleId,
      createdAt: createdAt ?? this.createdAt,
      titleName: titleName ?? this.titleName,
      departmentName: departmentName ?? this.departmentName,
    );
  }
}

class EmployeeBasicInfo {
  final String id;
  final String fullName;
  final String code;

  const EmployeeBasicInfo({
    required this.id,
    required this.fullName,
    required this.code,
  });
}
