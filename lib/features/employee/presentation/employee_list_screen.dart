// Màn: Danh sách nhân viên
// File này hiển thị danh sách nhân viên, cho phép thêm, sửa nhân viên
// và tạo tài khoản cho nhân viên chưa có tài khoản
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/app_employee.dart';
import '../domain/usecases/get_page_employee_usecase.dart';

// Widget chính cho màn danh sách nhân viên
class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  // UseCase để lấy danh sách nhân viên
  late final GetPageEmployeeUseCase _getPageUseCase;

  // Danh sách nhân viên và trạng thái
  List<AppEmployee> employees = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _getPageUseCase = resolve<GetPageEmployeeUseCase>();
    // Tải danh sách ban đầu
    _loadEmployees();
  }

  // Tải danh sách nhân viên từ API
  Future<void> _loadEmployees() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _getPageUseCase.call(pageIndex: 1, pageSize: 100);
      setState(() {
        employees = result;
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

  // Chuyển enum giới tính sang text tiếng Việt
  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Nam';
      case Gender.female:
        return 'Nữ';
    }
  }

  // Chuyển enum trạng thái sang text tiếng Việt
  String _getStatusText(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return 'Đang làm việc';
      case EmployeeStatus.inactive:
        return 'Tạm nghỉ';
      case EmployeeStatus.suspended:
        return 'Đã nghỉ việc';
    }
  }

  // Màu sắc cho từng trạng thái
  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return Colors.green;
      case EmployeeStatus.inactive:
        return Colors.orange;
      case EmployeeStatus.suspended:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách nhân viên'),
        actions: [
          // Nút thêm nhân viên mới
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.push<bool>('/employees/new');
              if (result == true) {
                _loadEmployees();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Hiển thị loading
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hiển thị lỗi
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Hiển thị thông báo khi không có dữ liệu
    if (employees.isEmpty) {
      return const Center(child: Text('Không có nhân viên nào'));
    }

    // Hiển thị danh sách (có pull-to-refresh)
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(employee.fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã: ${employee.code}'),
                  Text('Email: ${employee.email}'),
                  Row(
                    children: [
                      Text('Giới tính: ${_getGenderText(employee.gender)}'),
                      const SizedBox(width: 16),
                      // Badge hiển thị trạng thái
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            employee.status,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(employee.status),
                          style: TextStyle(
                            color: _getStatusColor(employee.status),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Hiển thị nếu nhân viên chưa có tài khoản
                  if (employee.userId == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Chưa có tài khoản',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút tạo tài khoản (chỉ hiện nếu chưa có tài khoản)
                  if (employee.userId == null)
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      color: Colors.blue,
                      tooltip: 'Tạo tài khoản',
                      onPressed: () async {
                        final result = await context.push<bool>(
                          '/employees/create-user/${employee.id}',
                        );
                        if (result == true) {
                          _loadEmployees();
                        }
                      },
                    ),
                  // Nút sửa nhân viên
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await context.push<bool>(
                        '/employees/edit/${employee.id}',
                      );
                      if (result == true) {
                        _loadEmployees();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
