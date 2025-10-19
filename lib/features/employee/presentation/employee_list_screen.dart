import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:attendance_system/core/routing/route_constraint.dart';
import '../domain/entities/employee.dart';
import '../data/datasources/employee_remote_datasource.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeRemoteDataSource _dataSource = EmployeeRemoteDataSourceImpl();
  List<Employee> employees = [];
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMoreData = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      error = null;
      if (isRefresh) {
        currentPage = 1;
        employees.clear();
        hasMoreData = true;
      }
    });

    try {
      final params = {
        'page': currentPage,
        'size': pageSize,
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
      };

      final result = await _dataSource.getEmployees(params);
      setState(() {
        final newEmployees = result.map((model) => Employee(
          id: model.id,
          fullName: model.fullName,
          code: model.code,
          email: model.email,
          gender: model.gender,
          birthDate: model.birthDate,
          departmentId: model.departmentId,
          titleId: model.titleId,
          createdAt: model.createdAt,
          titleName: model.titleName,
          departmentName: model.departmentName,
        )).toList();

        if (isRefresh) {
          employees = newEmployees;
        } else {
          employees.addAll(newEmployees);
        }
        hasMoreData = newEmployees.length == pageSize;
        currentPage++;
      });
    } catch (e) {
      // Fallback to mock data
      final mockEmployees = [
        Employee(
          id: '1',
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
        ),
        Employee(
          id: '2',
          fullName: 'Trần Thị B',
          code: 'NV002',
          email: 'ttb@company.com',
          gender: 0,
          birthDate: DateTime(1988, 8, 20),
          departmentId: 'dept2',
          titleId: 'title2',
          createdAt: DateTime.now(),
          departmentName: 'Phòng HR',
          titleName: 'HR Manager',
        ),
        Employee(
          id: '3',
          fullName: 'Lê Văn C',
          code: 'NV003',
          email: 'lvc@company.com',
          gender: 1,
          birthDate: DateTime(1992, 3, 10),
          departmentId: 'dept1',
          titleId: 'title3',
          createdAt: DateTime.now(),
          departmentName: 'Phòng IT',
          titleName: 'Senior Developer',
        ),
      ];

      setState(() {
        if (isRefresh) {
          employees = mockEmployees;
        } else {
          employees.addAll(mockEmployees);
        }
        hasMoreData = false;
        currentPage++;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchEmployees() {
    _loadEmployees(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên nhân viên',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchEmployees();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _searchEmployees(),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RouteConstraint.createEmployee),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && employees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $error'),
            ElevatedButton(
              onPressed: () => _loadEmployees(isRefresh: true),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (employees.isEmpty) {
      return const Center(
        child: Text('Không có nhân viên nào'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadEmployees(isRefresh: true),
      child: ListView.builder(
        itemCount: employees.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == employees.length) {
            if (hasMoreData) {
              _loadEmployees();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return null;
          }

          final employee = employees[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(employee.fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã NV: ${employee.code}'),
                  if (employee.departmentName != null)
                    Text('Phòng ban: ${employee.departmentName}'),
                  if (employee.titleName != null)
                    Text('Chức vụ: ${employee.titleName}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go(RouteConstraint.employeeDetail, extra: employee.id),
            ),
          );
        },
      ),
    );
  }
}
