import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:attendance_system/core/routing/route_constraint.dart';
import '../domain/entities/employee.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String? employeeId;

  const EmployeeDetailScreen({
    super.key,
    this.employeeId,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  Employee? employee;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadEmployeeDetail();
  }

  Future<void> _loadEmployeeDetail() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // TODO: Implement actual API call
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        employee = Employee(
          id: widget.employeeId ?? '1',
          fullName: 'Nguyễn Văn A',
          code: 'NV001',
          email: 'nva@company.com',
          gender: 1,
          birthDate: DateTime(1990, 5, 15),
          departmentId: 'dept1',
          titleId: 'title1',
          createdAt: DateTime.now(),
          departmentName: 'Phòng IT',
          titleName: 'Developer',
        );
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhân viên'),
        actions: [
          if (employee != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go(RouteConstraint.editEmployee, extra: employee!.id),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $error'),
            ElevatedButton(
              onPressed: _loadEmployeeDetail,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (employee == null) {
      return const Center(
        child: Text('Không tìm thấy thông tin nhân viên'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Thông tin cơ bản', [
            _buildInfoRow('Họ và tên', employee!.fullName),
            _buildInfoRow('Mã nhân viên', employee!.code),
            _buildInfoRow('Email', employee!.email),
            _buildInfoRow('Giới tính', _getGenderText(employee!.gender)),
            _buildInfoRow('Ngày sinh', 
                employee!.birthDate != null 
                    ? '${employee!.birthDate!.day}/${employee!.birthDate!.month}/${employee!.birthDate!.year}'
                    : 'Chưa cập nhật'),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Thông tin công việc', [
            _buildInfoRow('Phòng ban', employee!.departmentName ?? 'Chưa phân công'),
            _buildInfoRow('Chức vụ', employee!.titleName ?? 'Chưa phân công'),
            _buildInfoRow('Ngày tạo', 
                '${employee!.createdAt.day}/${employee!.createdAt.month}/${employee!.createdAt.year}'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getGenderText(int? gender) {
    switch (gender) {
      case 0:
        return 'Nam';
      case 1:
        return 'Nữ';
      default:
        return 'Chưa cập nhật';
    }
  }
}
