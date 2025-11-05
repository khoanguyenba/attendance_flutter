import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/attendance_history.dart';
import '../domain/usecases/get_page_attendance_history_usecase.dart';
import '../../employee/domain/entities/app_employee.dart';
import '../../employee/domain/usecases/get_page_employee_usecase.dart';
import '../../worktime/domain/entities/app_work_time.dart';
import '../../worktime/domain/usecases/get_page_work_time_usecase.dart';
import '../../user/domain/usecases/get_current_user_usecase.dart';
import 'create_attendance_history_screen.dart';

class AttendanceHistoryListScreen extends StatefulWidget {
  const AttendanceHistoryListScreen({super.key});

  @override
  State<AttendanceHistoryListScreen> createState() =>
      _AttendanceHistoryListScreenState();
}

class _AttendanceHistoryListScreenState
    extends State<AttendanceHistoryListScreen> {
  late final GetPageAttendanceHistoryUseCase _getPageUseCase;
  late final GetPageEmployeeUseCase _getEmployeesUseCase;
  late final GetPageWorkTimeUseCase _getWorkTimesUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  List<AppAttendanceHistory> attendanceHistories = [];
  Map<String, AppEmployee> employeesMap = {};
  Map<String, AppWorkTime> workTimesMap = {};
  bool isLoading = false;
  String? error;

  // User info
  String? _currentUserRole;
  String? _currentUserEmployeeId;
  bool _canSelectEmployee = false;

  // Filters
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _filterDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _getPageUseCase = resolve<GetPageAttendanceHistoryUseCase>();
    _getEmployeesUseCase = resolve<GetPageEmployeeUseCase>();
    _getWorkTimesUseCase = resolve<GetPageWorkTimeUseCase>();
    _getCurrentUserUseCase = resolve<GetCurrentUserUseCase>();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Get current user info
      final currentUser = await _getCurrentUserUseCase.call();
      if (currentUser != null) {
        _currentUserRole = currentUser.role;
        _currentUserEmployeeId = currentUser.employeeId;
        _canSelectEmployee =
            currentUser.role.toLowerCase() == 'admin' ||
            currentUser.role.toLowerCase() == 'manager';

        // If not admin/manager, auto-select current employee
        if (!_canSelectEmployee) {
          _selectedEmployeeId = currentUser.employeeId;
        }
      }

      // Load employees for mapping
      final employees = await _getEmployeesUseCase.call(
        pageIndex: 1,
        pageSize: 1000,
      );

      // Load work times for mapping
      final workTimes = await _getWorkTimesUseCase.execute(
        pageIndex: 1,
        pageSize: 1000,
      );

      setState(() {
        employeesMap = {for (var e in employees) e.id: e};
        workTimesMap = {for (var w in workTimes) w.id: w};
      });

      await _loadAttendanceHistories();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadAttendanceHistories() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _getPageUseCase.call(
        pageIndex: 1,
        pageSize: 100,
        employeeId: _selectedEmployeeId,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        attendanceHistories = result;
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

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAttendanceHistories();
    }
  }

  void _clearFilters() {
    setState(() {
      // Only clear employee filter if user can select employee
      if (_canSelectEmployee) {
        _selectedEmployeeId = null;
      }
      _startDate = null;
      _endDate = null;
    });
    _loadAttendanceHistories();
  }

  String _getTypeText(AttendanceType type) {
    switch (type) {
      case AttendanceType.checkIn:
        return 'Vào';
      case AttendanceType.checkOut:
        return 'Ra';
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return 'Đúng giờ';
      case AttendanceStatus.late:
        return 'Trễ';
      case AttendanceStatus.early:
        return 'Sớm';
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.red;
      case AttendanceStatus.early:
        return Colors.orange;
    }
  }

  Color _getTypeColor(AttendanceType type) {
    switch (type) {
      case AttendanceType.checkIn:
        return Colors.blue;
      case AttendanceType.checkOut:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If this screen is embedded in a parent Scaffold (e.g. HomeScreen with its own AppBar)
    // we should not render a nested AppBar to avoid duplicate titles. In that case
    // render only the content. Otherwise render a full Scaffold with the AppBar/actions.
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    final content = Column(
      children: [
        if ((_canSelectEmployee && _selectedEmployeeId != null) ||
            _startDate != null ||
            _endDate != null)
          _buildFilterChips(),
        Expanded(child: _buildBody()),
      ],
    );

    if (hasParentScaffold) {
      // Provide floating action button and filter entry inside content when embedded
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Stack(
          children: [
            content,
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'filter_btn',
                    mini: true,
                    onPressed: _showFilterDialog,
                    child: const Icon(Icons.filter_alt),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'add_btn',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CreateAttendanceHistoryScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadAttendanceHistories();
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chấm công'),
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
                  builder: (context) => const CreateAttendanceHistoryScreen(),
                ),
              );
              if (result == true) {
                _loadAttendanceHistories();
              }
            },
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Wrap(
        spacing: 8,
        children: [
          if (_canSelectEmployee && _selectedEmployeeId != null)
            Chip(
              label: Text(
                'NV: ${employeesMap[_selectedEmployeeId]?.fullName ?? "Unknown"}',
              ),
              onDeleted: () {
                setState(() {
                  _selectedEmployeeId = null;
                });
                _loadAttendanceHistories();
              },
            ),
          if (_startDate != null && _endDate != null)
            Chip(
              label: Text(
                'Từ ${_filterDateFormat.format(_startDate!)} đến ${_filterDateFormat.format(_endDate!)}',
              ),
              onDeleted: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
                _loadAttendanceHistories();
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
        title: const Text('Lọc dữ liệu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_canSelectEmployee)
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
            if (_canSelectEmployee) const SizedBox(height: 16),
            ListTile(
              title: const Text('Khoảng thời gian'),
              subtitle: _startDate != null && _endDate != null
                  ? Text(
                      '${_filterDateFormat.format(_startDate!)} - ${_filterDateFormat.format(_endDate!)}',
                    )
                  : const Text('Chưa chọn'),
              trailing: const Icon(Icons.date_range),
              onTap: () {
                Navigator.pop(context);
                _selectDateRange();
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
              _loadAttendanceHistories();
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
              onPressed: _loadAttendanceHistories,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (attendanceHistories.isEmpty) {
      return const Center(child: Text('Không có lịch sử chấm công nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadAttendanceHistories,
      child: ListView.builder(
        itemCount: attendanceHistories.length,
        itemBuilder: (context, index) {
          final history = attendanceHistories[index];
          final employee = employeesMap[history.employeeId];
          final workTime = workTimesMap[history.workTimeId];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getTypeColor(history.type),
                child: Icon(
                  history.type == AttendanceType.checkIn
                      ? Icons.login
                      : Icons.logout,
                  color: Colors.white,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${workTime?.name ?? 'Unknown Work Time'} - ${_getTypeText(history.type)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee?.fullName ?? 'Unknown Employee',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_dateFormat.format(history.attendanceDate)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(history.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(history.status),
                      style: TextStyle(
                        color: _getStatusColor(history.status),
                        fontSize: 12,
                      ),
                    ),
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
