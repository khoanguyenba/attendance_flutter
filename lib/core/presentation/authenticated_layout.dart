import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:attendance_system/core/routing/route_constraint.dart';
import 'package:attendance_system/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:attendance_system/features/auth/data/repositories/user_repository_impl.dart';
import 'package:attendance_system/features/auth/domain/usecases/logout.dart';

class AuthenticatedLayout extends StatelessWidget {
  final Widget child;

  const AuthenticatedLayout({super.key, required this.child});

  Future<void> _logout(BuildContext context) async {
    try {
  final dataSource = UserRemoteDataSourceImpl(FirebaseAuth.instance);
      final repository = UserRepositoryImpl(dataSource);
      final logoutUseCase = Logout(repository);
      await logoutUseCase.call(null);
      if (context.mounted) {
        context.go(RouteConstraint.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hệ thống chấm công'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.go(RouteConstraint.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(currentLocation),
      onTap: (index) => _onTabTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
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
          icon: Icon(Icons.work),
          label: 'Chức vụ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wifi),
          label: 'WiFi',
        ),
      ],
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/attendance')) return 0;
    if (location.startsWith('/employees')) return 1;
    if (location.startsWith('/departments')) return 2;
    if (location.startsWith('/titles')) return 3;
    if (location.startsWith('/attendance-wifi')) return 4;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteConstraint.attendance);
        break;
      case 1:
        context.go(RouteConstraint.employees);
        break;
      case 2:
        context.go(RouteConstraint.departments);
        break;
      case 3:
        context.go(RouteConstraint.titles);
        break;
      case 4:
        context.go(RouteConstraint.attendanceWifi);
        break;
    }
  }
}
