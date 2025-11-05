import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/app_department.dart';
import '../domain/usecases/get_page_department_usecase.dart';
import '../domain/usecases/delete_department_usecase.dart';
import 'edit_department_screen.dart';

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  late final GetPageDepartmentUseCase _getPageUseCase;
  late final DeleteDepartmentUseCase _deleteUseCase;
  
  List<AppDepartment> departments = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _getPageUseCase = resolve<GetPageDepartmentUseCase>();
    _deleteUseCase = resolve<DeleteDepartmentUseCase>();
    
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _getPageUseCase.call(
        pageIndex: 1,
        pageSize: 100,
      );
      setState(() {
        departments = result;
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

  Future<void> _deleteDepartment(AppDepartment department) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phòng ban "${department.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _deleteUseCase.call(department.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa phòng ban thành công')),
          );
          _loadDepartments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách phòng ban'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.push<bool>('/departments/new');
              if (result == true) {
                _loadDepartments();
              }
            },
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
              onPressed: _loadDepartments,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (departments.isEmpty) {
      return const Center(
        child: Text('Không có phòng ban nào'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDepartments,
      child: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final department = departments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(department.name),
              subtitle: department.description != null
                  ? Text(department.description!)
                  : null,
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await context.push<bool>('/departments/edit/${department.id}');
                    if (result == true) {
                      _loadDepartments();
                    }
                  } else if (value == 'delete') {
                    _deleteDepartment(department);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}