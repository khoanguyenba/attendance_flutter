import 'package:attendance_system/core/di/injection.dart';
import 'package:attendance_system/features/user/domain/usecases/logout_usecase.dart';
import 'package:attendance_system/features/user/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter/material.dart';
import '../../features/attendance_history/presentation/attendance_history_list_screen.dart';
import '../../features/employee/presentation/employee_list_screen.dart';
import '../../features/department/presentation/department_list_screen.dart';
import '../../features/worktime/presentation/work_time_list_screen.dart';
import '../../features/leave_request/presentation/leave_request_list_screen.dart';
import '../../features/user/presentation/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _logoutUsecase = resolve<LogoutUsecase>();
    _getCurrentUserUseCase = resolve<GetCurrentUserUseCase>();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final currentUser = await _getCurrentUserUseCase.call();
      if (currentUser != null && mounted) {
        setState(() {
          _isAdmin =
              currentUser.role.toLowerCase() == 'admin' ||
              currentUser.role.toLowerCase() == 'manager';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Widget> get _screens {
    if (_isAdmin) {
      return const [
        AttendanceHistoryListScreen(),
        EmployeeListScreen(),
        DepartmentListScreen(),
        WorkTimeListScreen(),
        LeaveRequestListScreen(),
      ];
    } else {
      return const [
        AttendanceHistoryListScreen(),
        WorkTimeListScreen(),
        LeaveRequestListScreen(),
      ];
    }
  }

  List<String> get _titles {
    if (_isAdmin) {
      return const [
        'Lịch sử chấm công',
        'Nhân viên',
        'Phòng ban',
        'Ca làm việc',
        'Đơn nghỉ phép',
      ];
    } else {
      return const ['Lịch sử chấm công', 'Ca làm việc', 'Đơn nghỉ phép'];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    if (_isAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: 'Chấm công',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Nhân viên'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Phòng ban'),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Ca làm việc',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Nghỉ phép',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: 'Chấm công',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Ca làm việc',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Nghỉ phép',
        ),
      ];
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await _logoutUsecase.call();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}
