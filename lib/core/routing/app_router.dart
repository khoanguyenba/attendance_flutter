import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/user/presentation/login_screen.dart';
import '../presentation/authenticated_layout.dart';
import '../../features/attendance_history/presentation/attendance_history_list_screen.dart';
import '../../features/employee/presentation/employee_list_screen.dart';
import '../../features/department/presentation/department_list_screen.dart';
import '../../features/worktime/presentation/edit_work_time_screen.dart';
import '../../features/worktime/presentation/work_time_list_screen.dart';
import '../../features/leave_request/presentation/leave_request_list_screen.dart';
import '../../features/attendance_history/presentation/create_attendance_history_screen.dart';
import '../../features/leave_request/presentation/create_leave_request_screen.dart';
import '../../features/employee/presentation/edit_employee_screen.dart';
import '../../features/user/presentation/create_user_screen.dart';
import '../../features/department/presentation/edit_department_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(
          path: '/attendance',
          name: 'attendance',
          builder: (context, state) => const AttendanceHistoryListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'attendance_new',
              builder: (context, state) => const CreateAttendanceHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/employees',
          name: 'employees',
          builder: (context, state) => const EmployeeListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'employee_new',
              builder: (context, state) => const EditEmployeeScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              name: 'employee_edit',
              builder: (context, state) => EditEmployeeScreen(
                employeeId: state.pathParameters['id'],
              ),
            ),
            GoRoute(
              path: 'create-user/:employeeId',
              name: 'employee_create_user',
              builder: (context, state) => CreateUserScreen(
                employeeId: state.pathParameters['employeeId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/departments',
          name: 'departments',
          builder: (context, state) => const DepartmentListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'department_new',
              builder: (context, state) => const EditDepartmentScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              name: 'department_edit',
              builder: (context, state) => EditDepartmentScreen(
                departmentId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/worktimes',
          name: 'worktimes',
          builder: (context, state) => const WorkTimeListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'worktime_new',
              builder: (context, state) => const EditWorkTimeScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              name: 'worktime_edit',
              builder: (context, state) => EditWorkTimeScreen(
                workTimeId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/leave-requests',
          name: 'leave_requests',
          builder: (context, state) => const LeaveRequestListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: 'leave_request_new',
              builder: (context, state) => const CreateLeaveRequestScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);


