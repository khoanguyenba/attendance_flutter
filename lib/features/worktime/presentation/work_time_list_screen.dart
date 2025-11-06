// Màn: Danh sách ca làm việc
// File này hiển thị danh sách ca làm việc, cho phép lọc, làm mới, thêm, sửa, xóa
// Tất cả comment đều bằng tiếng Việt để dễ hiểu cho người phát triển VN
import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/app_work_time.dart';
import '../domain/usecases/get_page_work_time_usecase.dart';
import '../domain/usecases/delete_work_time_usecase.dart';
import '../../user/domain/usecases/get_current_user_usecase.dart';
import 'edit_work_time_screen.dart';
import 'package:go_router/go_router.dart';

// Widget chính cho màn danh sách ca làm việc
// - Là Stateful vì cần quản lý trạng thái (danh sách, loading, filter, quyền người dùng)
class WorkTimeListScreen extends StatefulWidget {
  const WorkTimeListScreen({super.key});

  @override
  State<WorkTimeListScreen> createState() => _WorkTimeListScreenState();
}

class _WorkTimeListScreenState extends State<WorkTimeListScreen> {
  // UseCase để lấy trang ca làm việc (phụ thuộc vào DI)
  late final GetPageWorkTimeUseCase _getPageUseCase;
  // UseCase để xóa ca làm việc
  late final DeleteWorkTimeUseCase _deleteUseCase;
  // UseCase để lấy người dùng hiện tại (xác định quyền)
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  // Dữ liệu và trạng thái hiển thị
  List<AppWorkTime> workTimes = []; // danh sách ca làm việc
  bool isLoading = false; // đang tải dữ liệu
  String? error; // lỗi (nếu có)

  // Thông tin người dùng hiện tại
  bool _canManageWorkTime = false; // true nếu user có quyền thêm/sửa/xóa

  // Bộ lọc: null = tất cả, true = đang hoạt động, false = không hoạt động
  bool? _filterIsActive;

  @override
  void initState() {
    super.initState();
    // Lấy các UseCase từ DI container
    _getPageUseCase = resolve<GetPageWorkTimeUseCase>();
    _deleteUseCase = resolve<DeleteWorkTimeUseCase>();
    _getCurrentUserUseCase = resolve<GetCurrentUserUseCase>();

    // Tải dữ liệu khởi tạo (quyền + danh sách)
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Tải trước quyền người dùng rồi mới tải danh sách ca làm việc
    await _loadUserRole();
    await _loadWorkTimes();
  }

  Future<void> _loadUserRole() async {
    try {
      final currentUser = await _getCurrentUserUseCase.call();
      if (currentUser != null && mounted) {
        setState(() {
          // Người dùng có quyền quản lý nếu role là admin hoặc manager
          _canManageWorkTime =
              currentUser.role.toLowerCase() == 'admin' ||
              currentUser.role.toLowerCase() == 'manager';
        });
      }
    } catch (e) {
      // Nếu gặp lỗi khi lấy user thì bỏ qua và giữ quyền mặc định là false
    }
  }

  Future<void> _loadWorkTimes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _getPageUseCase.execute(
        pageIndex: 1,
        pageSize: 100,
        isActive: _filterIsActive,
      );
      setState(() {
        // Cập nhật danh sách ca làm việc nhận từ usecase
        workTimes = result;
      });
    } catch (e) {
      setState(() {
        // Lưu thông báo lỗi để hiển thị lên UI
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteWorkTime(AppWorkTime workTime) async {
    // Hiển thị dialog xác nhận trước khi xóa
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa ca làm việc "${workTime.name}"?',
        ),
        actions: [
          // Hủy: trả về false
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          // Xóa: trả về true (màu đỏ để nhấn mạnh)
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
        // Gọi usecase để xóa
        await _deleteUseCase.execute(workTime.id);
        if (mounted) {
          // Thông báo thành công và làm mới danh sách
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa ca làm việc thành công')),
          );
          _loadWorkTimes();
        }
      } catch (e) {
        // Nếu lỗi khi xóa, hiện snackbar với nội dung lỗi
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Sử dụng biến tạm để chọn filter trong dialog (không commit ngay)
        bool? tempFilter = _filterIsActive;
        return AlertDialog(
          title: const Text('Lọc ca làm việc'),
          // StatefulBuilder để quản lý state nội bộ của dialog
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tuỳ chọn: Tất cả
                  RadioListTile<bool?>(
                    title: const Text('Tất cả'),
                    value: null,
                    groupValue: tempFilter,
                    onChanged: (value) {
                      setState(() {
                        tempFilter = value;
                      });
                    },
                  ),
                  // Tuỳ chọn: Đang hoạt động
                  RadioListTile<bool?>(
                    title: const Text('Đang hoạt động'),
                    value: true,
                    groupValue: tempFilter,
                    onChanged: (value) {
                      setState(() {
                        tempFilter = value;
                      });
                    },
                  ),
                  // Tuỳ chọn: Không hoạt động
                  RadioListTile<bool?>(
                    title: const Text('Không hoạt động'),
                    value: false,
                    groupValue: tempFilter,
                    onChanged: (value) {
                      setState(() {
                        tempFilter = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            // Hủy: đóng dialog và không thay đổi filter
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            // Áp dụng: cập nhật filter và tải lại danh sách
            TextButton(
              onPressed: () {
                setState(() {
                  _filterIsActive = tempFilter;
                });
                Navigator.pop(context);
                _loadWorkTimes();
              },
              child: const Text('Áp dụng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ca làm việc'),
        actions: [
          if (_filterIsActive != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Xóa bộ lọc',
              onPressed: () {
                setState(() {
                  _filterIsActive = null;
                });
                _loadWorkTimes();
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
          if (_canManageWorkTime)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                // Chuyển sang màn thêm ca làm việc, nếu kết quả true thì reload
                final result = await context.push<bool>('/worktimes/new');
                if (result == true) {
                  _loadWorkTimes();
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWorkTimes,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (workTimes.isEmpty) {
      // Nếu không có ca làm việc phù hợp với filter
      return const Center(child: Text('Không có ca làm việc nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadWorkTimes,
      child: ListView.builder(
        itemCount: workTimes.length,
        itemBuilder: (context, index) {
          final workTime = workTimes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: workTime.isActive ? Colors.green : Colors.grey,
                child: Icon(
                  workTime.isActive ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
              ),
              title: Text(workTime.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.login, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('Vào: ${workTime.validCheckInTime}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.logout, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('Ra: ${workTime.validCheckOutTime}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: workTime.isActive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      workTime.isActive ? 'Đang hoạt động' : 'Không hoạt động',
                      style: TextStyle(
                        color: workTime.isActive ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: _canManageWorkTime
                  ? PopupMenuButton(
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
                          // Điều hướng sang màn sửa; nếu true => refresh
                          final result = await context.push<bool>(
                            '/worktimes/edit/${workTime.id}',
                          );
                          if (result == true) {
                            _loadWorkTimes();
                          }
                        } else if (value == 'delete') {
                          _deleteWorkTime(workTime);
                        }
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
