import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/leave_request.dart';
import '../domain/usecases/get_page_leave_request_usecase.dart';
import '../domain/usecases/delete_leave_request_usecase.dart';
import '../domain/usecases/approve_leave_request_usecase.dart';
import '../domain/usecases/reject_leave_request_usecase.dart';
import '../../employee/domain/entities/app_employee.dart';
import '../../employee/domain/usecases/get_page_employee_usecase.dart';
import '../../user/domain/usecases/get_current_user_usecase.dart';
import 'create_leave_request_screen.dart';

class LeaveRequestListScreen extends StatefulWidget {
  const LeaveRequestListScreen({super.key});

  @override
  State<LeaveRequestListScreen> createState() => _LeaveRequestListScreenState();
}

class _LeaveRequestListScreenState extends State<LeaveRequestListScreen> {
  late final GetPageLeaveRequestUseCase _getPageUseCase;
  late final DeleteLeaveRequestUseCase _deleteUseCase;
  late final ApproveLeaveRequestUseCase _approveUseCase;
  late final RejectLeaveRequestUseCase _rejectUseCase;
  late final GetPageEmployeeUseCase _getEmployeesUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  List<AppLeaveRequest> leaveRequests = [];
  Map<String, AppEmployee> employeesMap = {};
  String? currentUserEmployeeId;
  bool isLoading = false;
  String? error;

  // Filters
  String? _selectedEmployeeId;
  LeaveStatus? _selectedStatus;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _getPageUseCase = resolve<GetPageLeaveRequestUseCase>();
    _deleteUseCase = resolve<DeleteLeaveRequestUseCase>();
    _approveUseCase = resolve<ApproveLeaveRequestUseCase>();
    _rejectUseCase = resolve<RejectLeaveRequestUseCase>();
    _getEmployeesUseCase = resolve<GetPageEmployeeUseCase>();
    _getCurrentUserUseCase = resolve<GetCurrentUserUseCase>();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load current user
      final currentUser = await _getCurrentUserUseCase.call();
      if (currentUser != null) {
        currentUserEmployeeId = currentUser.employeeId;
      }

      // Load employees for mapping
      final employees = await _getEmployeesUseCase.call(
        pageIndex: 1,
        pageSize: 1000,
      );

      setState(() {
        employeesMap = {for (var e in employees) e.id: e};
      });

      await _loadLeaveRequests();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadLeaveRequests() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _getPageUseCase.call(
        pageIndex: 1,
        pageSize: 100,
        employeeId: _selectedEmployeeId,
        status: _selectedStatus,
      );
      setState(() {
        leaveRequests = result;
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

  Future<void> _deleteLeaveRequest(AppLeaveRequest leaveRequest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đơn nghỉ phép này?'),
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
        await _deleteUseCase.call(leaveRequest.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa đơn nghỉ phép thành công')),
          );
          _loadLeaveRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  Future<void> _approveLeaveRequest(AppLeaveRequest leaveRequest) async {
    if (currentUserEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xác định thông tin người duyệt'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận phê duyệt'),
        content: const Text(
          'Bạn có chắc chắn muốn phê duyệt đơn nghỉ phép này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Phê duyệt'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _approveUseCase.call(leaveRequest.id, currentUserEmployeeId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phê duyệt đơn nghỉ phép thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadLeaveRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _rejectLeaveRequest(AppLeaveRequest leaveRequest) async {
    if (currentUserEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xác định thông tin người duyệt'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: const Text('Bạn có chắc chắn muốn từ chối đơn nghỉ phép này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _rejectUseCase.call(leaveRequest.id, currentUserEmployeeId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối đơn nghỉ phép'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadLeaveRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedEmployeeId = null;
      _selectedStatus = null;
    });
    _loadLeaveRequests();
  }

  String _getStatusText(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return 'Chờ duyệt';
      case LeaveStatus.approved:
        return 'Đã duyệt';
      case LeaveStatus.rejected:
        return 'Từ chối';
    }
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Icons.schedule;
      case LeaveStatus.approved:
        return Icons.check_circle;
      case LeaveStatus.rejected:
        return Icons.cancel;
    }
  }

  int _calculateDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn nghỉ phép'),
        actions: [
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
                  builder: (context) => const CreateLeaveRequestScreen(),
                ),
              );
              if (result == true) {
                _loadLeaveRequests();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedEmployeeId != null || _selectedStatus != null)
            _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedEmployeeId != null)
            Chip(
              label: Text(
                'NV: ${employeesMap[_selectedEmployeeId]?.fullName ?? "Unknown"}',
              ),
              onDeleted: () {
                setState(() {
                  _selectedEmployeeId = null;
                });
                _loadLeaveRequests();
              },
            ),
          if (_selectedStatus != null)
            Chip(
              label: Text('Trạng thái: ${_getStatusText(_selectedStatus!)}'),
              onDeleted: () {
                setState(() {
                  _selectedStatus = null;
                });
                _loadLeaveRequests();
              },
            ),
          TextButton.icon(
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Xóa lọc'),
            onPressed: _clearFilters,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc đơn nghỉ phép'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedEmployeeId,
              decoration: const InputDecoration(
                labelText: 'Nhân viên',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả')),
                ...employeesMap.values.map((employee) {
                  return DropdownMenuItem(
                    value: employee.id,
                    child: Text(employee.fullName),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LeaveStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả')),
                ...LeaveStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Xóa lọc'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadLeaveRequests();
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
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
              onPressed: _loadLeaveRequests,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (leaveRequests.isEmpty) {
      return const Center(child: Text('Không có đơn nghỉ phép nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadLeaveRequests,
      child: ListView.builder(
        itemCount: leaveRequests.length,
        itemBuilder: (context, index) {
          final leaveRequest = leaveRequests[index];
          final employee = employeesMap[leaveRequest.employeeId];
          final approvedBy = employeesMap[leaveRequest.approvedById];
          final days = _calculateDays(
            leaveRequest.startDate,
            leaveRequest.endDate,
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(leaveRequest.status),
                child: Icon(
                  _getStatusIcon(leaveRequest.status),
                  color: Colors.white,
                ),
              ),
              title: Text(employee?.fullName ?? 'Unknown Employee'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_dateFormat.format(leaveRequest.startDate)} - ${_dateFormat.format(leaveRequest.endDate)}',
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$days ngày',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            leaveRequest.status,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(leaveRequest.status),
                          style: TextStyle(
                            color: _getStatusColor(leaveRequest.status),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteLeaveRequest(leaveRequest),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lý do:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(leaveRequest.reason),
                      const SizedBox(height: 12),
                      if (approvedBy != null) ...[
                        Text(
                          leaveRequest.status == LeaveStatus.rejected
                              ? 'Người từ chối:'
                              : 'Người phê duyệt:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(approvedBy.fullName),
                        const SizedBox(height: 12),
                      ],
                      if (leaveRequest.status == LeaveStatus.pending) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _approveLeaveRequest(leaveRequest),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Phê duyệt'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _rejectLeaveRequest(leaveRequest),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Từ chối'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
