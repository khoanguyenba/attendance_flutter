import 'package:attendance_system/features/department/domain/entities/app_department.dart';

abstract class AppDepartmentRepository {
  Future<AppDepartment> createDepartment({
    required String code,
    required String name,
    String? description,
  });

  Future<void> updateDepartment({
    required String id,
    required String code,
    required String name,
    String? description,
  });

  Future<void> deleteDepartment(String id);

  Future<AppDepartment?> getDepartmentById(String id);

  Future<List<AppDepartment>> getPageDepartment({
    int pageIndex = 1,
    int pageSize = 20,
    String? code,
    String? name,
  });
}
