import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.fullName,
    required super.code,
    required super.email,
    super.gender,
    super.birthDate,
    super.departmentId,
    super.titleId,
    required super.createdAt,
    super.titleName,
    super.departmentName,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      code: json['code'] as String,
      email: json['email'] as String? ?? '',
      gender: json['gender'] as int?,
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      departmentId: json['departmentId'] as String?,
      titleId: json['titleId'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      titleName: json['title']?['name'] as String?,
      departmentName: json['department']?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'code': code,
      'email': email,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'departmentId': departmentId,
      'titleId': titleId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmployeeModel.fromCreateJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      fullName: '',
      code: '',
      email: '',
      createdAt: DateTime.now(),
    );
  }

  factory EmployeeModel.fromListJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      code: json['code'] as String,
      email: '',
      gender: json['gender'] as int?,
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      departmentId: json['departmentId'] as String?,
      titleId: json['titleId'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }
}

class EmployeeBasicInfoModel extends EmployeeBasicInfo {
  const EmployeeBasicInfoModel({
    required super.id,
    required super.fullName,
    required super.code,
  });

  factory EmployeeBasicInfoModel.fromJson(Map<String, dynamic> json) {
    return EmployeeBasicInfoModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      code: json['code'] as String,
    );
  }
}
