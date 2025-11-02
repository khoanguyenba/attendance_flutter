import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:attendance_system/core/data/datasources/base_remote_datasource.dart';
import 'package:attendance_system/features/user/data/datasources/user_remote_datasource.dart';
import 'package:attendance_system/features/user/data/repositories/app_user_repository_impl.dart';
import 'package:attendance_system/features/user/domain/repositories/app_user_repository.dart';
import 'package:attendance_system/features/user/domain/usecases/login_usecase.dart';
import 'package:attendance_system/features/user/domain/usecases/get_current_user_usecase.dart';
import 'package:attendance_system/features/employee/data/datasources/employee_remote_datasource.dart';
import 'package:attendance_system/features/employee/data/repositories/app_employee_repository_impl.dart';
import 'package:attendance_system/features/employee/domain/repositories/app_employee_repository.dart';
import 'package:attendance_system/features/employee/domain/usecases/create_employee_usecase.dart';
import 'package:attendance_system/features/employee/domain/usecases/update_employee_usecase.dart';
import 'package:attendance_system/features/employee/domain/usecases/get_employee_by_id_usecase.dart';
import 'package:attendance_system/features/employee/domain/usecases/get_page_employee_usecase.dart';
import 'package:attendance_system/features/department/data/datasources/department_remote_datasource.dart';
import 'package:attendance_system/features/department/data/repositories/app_department_repository_impl.dart';
import 'package:attendance_system/features/department/domain/repositories/app_department_repository.dart';
import 'package:attendance_system/features/department/domain/usecases/create_department_usecase.dart';
import 'package:attendance_system/features/department/domain/usecases/update_department_usecase.dart';
import 'package:attendance_system/features/department/domain/usecases/delete_department_usecase.dart';
import 'package:attendance_system/features/department/domain/usecases/get_department_by_id_usecase.dart';
import 'package:attendance_system/features/department/domain/usecases/get_page_department_usecase.dart';
import 'package:attendance_system/features/attendance_history/data/datasources/attendance_history_remote_datasource.dart';
import 'package:attendance_system/features/attendance_history/data/repositories/app_attendance_history_repository_impl.dart';
import 'package:attendance_system/features/attendance_history/domain/repositories/app_attendance_history_repository.dart';
import 'package:attendance_system/features/attendance_history/domain/usecases/create_attendance_history_usecase.dart';
import 'package:attendance_system/features/attendance_history/domain/usecases/delete_attendance_history_usecase.dart';
import 'package:attendance_system/features/attendance_history/domain/usecases/get_attendance_history_by_id_usecase.dart';
import 'package:attendance_system/features/attendance_history/domain/usecases/get_page_attendance_history_usecase.dart';
import 'package:attendance_system/features/leave_request/data/datasources/leave_request_remote_datasource.dart';
import 'package:attendance_system/features/leave_request/data/repositories/app_leave_request_repository_impl.dart';
import 'package:attendance_system/features/leave_request/domain/repositories/app_leave_request_repository.dart';
import 'package:attendance_system/features/leave_request/domain/usecases/create_leave_request_usecase.dart';
import 'package:attendance_system/features/leave_request/domain/usecases/delete_leave_request_usecase.dart';
import 'package:attendance_system/features/leave_request/domain/usecases/get_leave_request_by_id_usecase.dart';
import 'package:attendance_system/features/leave_request/domain/usecases/get_page_leave_request_usecase.dart';
import 'package:attendance_system/features/worktime/data/datasources/work_time_remote_datasource.dart';
import 'package:attendance_system/features/worktime/data/repositories/app_work_time_repository_impl.dart';
import 'package:attendance_system/features/worktime/domain/repositories/app_work_time_repository.dart';
import 'package:attendance_system/features/worktime/domain/usecases/create_work_time_usecase.dart';
import 'package:attendance_system/features/worktime/domain/usecases/update_work_time_usecase.dart';
import 'package:attendance_system/features/worktime/domain/usecases/delete_work_time_usecase.dart';
import 'package:attendance_system/features/worktime/domain/usecases/get_work_time_by_id_usecase.dart';
import 'package:attendance_system/features/worktime/domain/usecases/get_page_work_time_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Core singletons
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<UserRemoteDataSourceImpl>(
    () => UserRemoteDataSourceImpl(getIt<Dio>(), getIt<FlutterSecureStorage>()),
  );

  // Aliases
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => getIt<UserRemoteDataSourceImpl>(),
  );
  getIt.registerLazySingleton<BaseRemoteDataSource>(
    () => getIt<UserRemoteDataSourceImpl>(),
  );

  // Repository
  getIt.registerLazySingleton<AppUserRepository>(
    () => AppUserRepositoryImpl(getIt<UserRemoteDataSource>()),
  );

  // Employee datasource & repository
  getIt.registerLazySingleton<EmployeeRemoteDataSourceImpl>(
    () => EmployeeRemoteDataSourceImpl(
      getIt<Dio>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<EmployeeRemoteDataSource>(
    () => getIt<EmployeeRemoteDataSourceImpl>(),
  );

  getIt.registerLazySingleton<AppEmployeeRepository>(
    () => AppEmployeeRepositoryImpl(getIt<EmployeeRemoteDataSource>()),
  );

  // Department datasource & repository
  getIt.registerLazySingleton<DepartmentRemoteDataSourceImpl>(
    () => DepartmentRemoteDataSourceImpl(
      getIt<Dio>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<DepartmentRemoteDataSource>(
    () => getIt<DepartmentRemoteDataSourceImpl>(),
  );

  getIt.registerLazySingleton<AppDepartmentRepository>(
    () => AppDepartmentRepositoryImpl(getIt<DepartmentRemoteDataSource>()),
  );

  // AttendanceHistory datasource & repository
  getIt.registerLazySingleton<AttendanceHistoryRemoteDataSourceImpl>(
    () => AttendanceHistoryRemoteDataSourceImpl(
      getIt<Dio>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<AttendanceHistoryRemoteDataSource>(
    () => getIt<AttendanceHistoryRemoteDataSourceImpl>(),
  );

  getIt.registerLazySingleton<AppAttendanceHistoryRepository>(
    () => AppAttendanceHistoryRepositoryImpl(
      getIt<AttendanceHistoryRemoteDataSource>(),
    ),
  );

  // LeaveRequest datasource & repository
  getIt.registerLazySingleton<LeaveRequestRemoteDataSourceImpl>(
    () => LeaveRequestRemoteDataSourceImpl(
      getIt<Dio>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<LeaveRequestRemoteDataSource>(
    () => getIt<LeaveRequestRemoteDataSourceImpl>(),
  );

  getIt.registerLazySingleton<AppLeaveRequestRepository>(
    () => AppLeaveRequestRepositoryImpl(getIt<LeaveRequestRemoteDataSource>()),
  );

  // WorkTime datasource & repository
  getIt.registerLazySingleton<WorkTimeRemoteDataSourceImpl>(
    () => WorkTimeRemoteDataSourceImpl(
      getIt<Dio>(),
      getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<WorkTimeRemoteDataSource>(
    () => getIt<WorkTimeRemoteDataSourceImpl>(),
  );

  getIt.registerLazySingleton<AppWorkTimeRepository>(
    () => AppWorkTimeRepositoryImpl(getIt<WorkTimeRemoteDataSource>()),
  );

  // Usecases - register as factories (new instance each resolve)
  getIt.registerFactory(() => LoginUseCase(getIt<AppUserRepository>()));
  getIt.registerFactory(
    () => GetCurrentUserUseCase(getIt<AppUserRepository>()),
  );
  // Employee usecases
  getIt.registerFactory(
    () => CreateEmployeeUseCase(getIt<AppEmployeeRepository>()),
  );
  getIt.registerFactory(
    () => UpdateEmployeeUseCase(getIt<AppEmployeeRepository>()),
  );
  getIt.registerFactory(
    () => GetEmployeeByIdUseCase(getIt<AppEmployeeRepository>()),
  );
  getIt.registerFactory(
    () => GetPageEmployeeUseCase(getIt<AppEmployeeRepository>()),
  );
  // Department usecases
  getIt.registerFactory(
    () => CreateDepartmentUseCase(getIt<AppDepartmentRepository>()),
  );
  getIt.registerFactory(
    () => UpdateDepartmentUseCase(getIt<AppDepartmentRepository>()),
  );
  getIt.registerFactory(
    () => DeleteDepartmentUseCase(getIt<AppDepartmentRepository>()),
  );
  getIt.registerFactory(
    () => GetDepartmentByIdUseCase(getIt<AppDepartmentRepository>()),
  );
  getIt.registerFactory(
    () => GetPageDepartmentUseCase(getIt<AppDepartmentRepository>()),
  );
  // AttendanceHistory usecases
  getIt.registerFactory(
    () =>
        CreateAttendanceHistoryUseCase(getIt<AppAttendanceHistoryRepository>()),
  );
  getIt.registerFactory(
    () =>
        DeleteAttendanceHistoryUseCase(getIt<AppAttendanceHistoryRepository>()),
  );
  getIt.registerFactory(
    () => GetAttendanceHistoryByIdUseCase(
      getIt<AppAttendanceHistoryRepository>(),
    ),
  );
  getIt.registerFactory(
    () => GetPageAttendanceHistoryUseCase(
      getIt<AppAttendanceHistoryRepository>(),
    ),
  );
  // LeaveRequest usecases
  getIt.registerFactory(
    () => CreateLeaveRequestUseCase(getIt<AppLeaveRequestRepository>()),
  );
  // Update usecase for LeaveRequest removed because API has no update endpoint
  getIt.registerFactory(
    () => DeleteLeaveRequestUseCase(getIt<AppLeaveRequestRepository>()),
  );
  getIt.registerFactory(
    () => GetLeaveRequestByIdUseCase(getIt<AppLeaveRequestRepository>()),
  );
  getIt.registerFactory(
    () => GetPageLeaveRequestUseCase(getIt<AppLeaveRequestRepository>()),
  );
  // WorkTime usecases
  getIt.registerFactory(
    () => CreateWorkTimeUseCase(getIt<AppWorkTimeRepository>()),
  );
  getIt.registerFactory(
    () => UpdateWorkTimeUseCase(getIt<AppWorkTimeRepository>()),
  );
  getIt.registerFactory(
    () => DeleteWorkTimeUseCase(getIt<AppWorkTimeRepository>()),
  );
  getIt.registerFactory(
    () => GetWorkTimeByIdUseCase(getIt<AppWorkTimeRepository>()),
  );
  getIt.registerFactory(
    () => GetPageWorkTimeUseCase(getIt<AppWorkTimeRepository>()),
  );
}

/// Convenience getters
T resolve<T extends Object>() => getIt<T>();
