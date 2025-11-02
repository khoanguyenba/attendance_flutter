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

  final List<Widget> _screens = const [
    AttendanceHistoryListScreen(),
    EmployeeListScreen(),
    DepartmentListScreen(),
    WorkTimeListScreen(),
    LeaveRequestListScreen(),
  ];

  final List<String> _titles = const [
    'Lịch sử chấm công',
    'Nhân viên',
    'Phòng ban',
    'Ca làm việc',
    'Đơn nghỉ phép',
  ];

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

    if (confirmed == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Chấm công',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Nhân viên',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Phòng ban',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Ca làm việc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Nghỉ phép',
          ),
        ],
      ),
    );
  }
}