import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/app_work_time.dart';
import '../domain/usecases/get_page_work_time_usecase.dart';
import '../domain/usecases/delete_work_time_usecase.dart';
import 'edit_work_time_screen.dart';

class WorkTimeListScreen extends StatefulWidget {
  const WorkTimeListScreen({super.key});

  @override
  State<WorkTimeListScreen> createState() => _WorkTimeListScreenState();
}

class _WorkTimeListScreenState extends State<WorkTimeListScreen> {
  late final GetPageWorkTimeUseCase _getPageUseCase;
  late final DeleteWorkTimeUseCase _deleteUseCase;
  
  List<AppWorkTime> workTimes = [];
  bool isLoading = false;
  String? error;

  // Filter
  bool? _filterIsActive;

  @override
  void initState() {
    super.initState();
    _getPageUseCase = resolve<GetPageWorkTimeUseCase>();
    _deleteUseCase = resolve<DeleteWorkTimeUseCase>();
    
    _loadWorkTimes();
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
        workTimes = result;
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

  Future<void> _deleteWorkTime(AppWorkTime workTime) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa ca làm việc "${workTime.name}"?'),
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
        await _deleteUseCase.execute(workTime.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa ca làm việc thành công')),
          );
          _loadWorkTimes();
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

  void _showFilterDialog() async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => FilterDialog(currentFilter: _filterIsActive),
    );
    
    // Nếu user nhấn "Áp dụng", result sẽ chứa giá trị filter mới
    if (result != null) {
      setState(() {
        _filterIsActive = result;
      });
      _loadWorkTimes();
    }
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditWorkTimeScreen(), // null workTimeId = create mode
                ),
              );
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
      return const Center(
        child: Text('Không có ca làm việc nào'),
      );
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
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditWorkTimeScreen(
                          workTimeId: workTime.id,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadWorkTimes();
                    }
                  } else if (value == 'delete') {
                    _deleteWorkTime(workTime);
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

// Widget riêng cho Filter Dialog - Dễ hiểu hơn StatefulBuilder
class FilterDialog extends StatefulWidget {
  final bool? currentFilter;

  const FilterDialog({
    super.key,
    required this.currentFilter,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  bool? selectedFilter;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị từ filter hiện tại
    selectedFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lọc ca làm việc'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<bool?>(
            title: const Text('Tất cả'),
            value: null,
            groupValue: selectedFilter,
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
          ),
          RadioListTile<bool?>(
            title: const Text('Đang hoạt động'),
            value: true,
            groupValue: selectedFilter,
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
          ),
          RadioListTile<bool?>(
            title: const Text('Không hoạt động'),
            value: false,
            groupValue: selectedFilter,
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Đóng dialog mà không trả về gì (user hủy)
            Navigator.pop(context);
          },
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            // Trả về giá trị filter đã chọn
            Navigator.pop(context, selectedFilter);
          },
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }
}

