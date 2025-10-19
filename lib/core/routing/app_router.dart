import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:attendance_system/core/routing/route_constraint.dart';
import 'package:attendance_system/core/presentation/authenticated_layout.dart';
import 'package:attendance_system/features/auth/presentation/login_screen.dart';
import 'package:attendance_system/features/auth/presentation/register_screen.dart';
import 'package:attendance_system/features/attendance/presentation/attendance_screen.dart';
import 'package:attendance_system/features/attendance/presentation/attendance_history_screen.dart';
import 'package:attendance_system/features/employee/presentation/employee_list_screen.dart';
import 'package:attendance_system/features/employee/presentation/employee_detail_screen.dart';
import 'package:attendance_system/features/employee/presentation/create_employee_screen.dart';
import 'package:attendance_system/features/employee/presentation/edit_employee_screen.dart';
import 'package:attendance_system/features/department/presentation/department_list_screen.dart';
import 'package:attendance_system/features/department/presentation/create_department_screen.dart';
import 'package:attendance_system/features/department/presentation/edit_department_screen.dart';
import 'package:attendance_system/features/title/presentation/title_list_screen.dart';
import 'package:attendance_system/features/title/presentation/create_title_screen.dart';
import 'package:attendance_system/features/title/presentation/edit_title_screen.dart';
import 'package:attendance_system/features/attendance_wifi/presentation/attendance_wifi_list_screen.dart';
import 'package:attendance_system/features/system_notification/presentation/notification_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstraint.login,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoggingIn = state.matchedLocation == RouteConstraint.login;
      final isRegistering = state.matchedLocation == RouteConstraint.register;

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return RouteConstraint.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstraint.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstraint.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AuthenticatedLayout(child: child),
        routes: [
          GoRoute(
            path: RouteConstraint.home,
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: RouteConstraint.attendance,
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: RouteConstraint.attendanceHistory,
            builder: (context, state) => const AttendanceHistoryScreen(),
          ),
          GoRoute(
            path: RouteConstraint.employees,
            builder: (context, state) => const EmployeeListScreen(),
          ),
          GoRoute(
            path: RouteConstraint.employeeDetail,
            builder: (context, state) {
              final employeeId = state.extra as String?;
              return EmployeeDetailScreen(employeeId: employeeId);
            },
          ),
          GoRoute(
            path: RouteConstraint.createEmployee,
            builder: (context, state) => const CreateEmployeeScreen(),
          ),
          GoRoute(
            path: RouteConstraint.editEmployee,
            builder: (context, state) {
              final employeeId = state.extra as String?;
              return EditEmployeeScreen(employeeId: employeeId);
            },
          ),
          GoRoute(
            path: RouteConstraint.departments,
            builder: (context, state) => const DepartmentListScreen(),
          ),
          GoRoute(
            path: RouteConstraint.createDepartment,
            builder: (context, state) => const CreateDepartmentScreen(),
          ),
          GoRoute(
            path: RouteConstraint.editDepartment,
            builder: (context, state) {
              final departmentId = state.extra as String?;
              return EditDepartmentScreen(departmentId: departmentId);
            },
          ),
          GoRoute(
            path: RouteConstraint.titles,
            builder: (context, state) => const TitleListScreen(),
          ),
          GoRoute(
            path: RouteConstraint.createTitle,
            builder: (context, state) => const CreateTitleScreen(),
          ),
          GoRoute(
            path: RouteConstraint.editTitle,
            builder: (context, state) {
              final titleId = state.extra as String?;
              return EditTitleScreen(titleId: titleId);
            },
          ),
          GoRoute(
            path: RouteConstraint.attendanceWifi,
            builder: (context, state) => const AttendanceWiFiListScreen(),
          ),
          GoRoute(
            path: RouteConstraint.notifications,
            builder: (context, state) => const NotificationListScreen(),
          ),
        ],
      ),
    ],
  );
}
