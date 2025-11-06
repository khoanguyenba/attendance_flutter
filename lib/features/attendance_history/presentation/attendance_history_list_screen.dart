// Màn: Lịch sử chấm công
// File này hiển thị lịch sử chấm công, cho phép lọc theo nhân viên/ngày
// và thêm bản ghi chấm công mới
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

// Widget chính cho màn lịch sử chấm công
class AttendanceHistoryListScreen extends StatefulWidget {
  const AttendanceHistoryListScreen({super.key});

  @override
  State<AttendanceHistoryListScreen> createState() =>
      _AttendanceHistoryListScreenState();
}

class _AttendanceHistoryListScreenState
    extends State<AttendanceHistoryListScreen> {
  // UseCase để lấy lịch sử, nhân viên, ca làm việc, user hiện tại
  late final GetPageAttendanceHistoryUseCase _getPageUseCase;
  late final GetPageEmployeeUseCase _getEmployeesUseCase;
  late final GetPageWorkTimeUseCase _getWorkTimesUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  // Dữ liệu: lịch sử chấm công, map nhân viên và ca làm việc (để hiển thị tên)
  List<AppAttendanceHistory> attendanceHistories = [];
  Map<String, AppEmployee> employeesMap = {};
  Map<String, AppWorkTime> workTimesMap = {};
  bool isLoading = false;
  String? error;

  // Thông tin user hiện tại và quyền
  String? _currentUserRole;
  String? _currentUserEmployeeId;
  bool _canSelectEmployee = false; // true nếu admin/manager

  // Bộ lọc: theo nhân viên và khoảng thời gian
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _filterDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Lấy UseCase từ DI
    _getPageUseCase = resolve<GetPageAttendanceHistoryUseCase>();
    _getEmployeesUseCase = resolve<GetPageEmployeeUseCase>();
    _getWorkTimesUseCase = resolve<GetPageWorkTimeUseCase>();
    _getCurrentUserUseCase = resolve<GetCurrentUserUseCase>();

    // Tải dữ liệu ban đầu
    _loadInitialData();
  }

  // Tải dữ liệu ban đầu: user, nhân viên, ca làm việc, lịch sử
  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load user hiện tại để kiểm tra quyền
      final currentUser = await _getCurrentUserUseCase.call();
      if (currentUser != null) {
        _currentUserRole = currentUser.role;
        _currentUserEmployeeId = currentUser.employeeId;
        _canSelectEmployee =
            currentUser.role.toLowerCase() == 'admin' ||
            currentUser.role.toLowerCase() == 'manager';

        // Nếu không phải admin/manager, tự động lọc theo nhân viên hiện tại
        if (!_canSelectEmployee) {
          _selectedEmployeeId = currentUser.employeeId;
        }
      }

      // Load danh sách nhân viên (để map ID -> tên)
      final employees = await _getEmployeesUseCase.call(
        pageIndex: 1,
        pageSize: 1000,
      );

      // Load danh sách ca làm việc (để map ID -> tên)
      final workTimes = await _getWorkTimesUseCase.execute(
        pageIndex: 1,
        pageSize: 1000,
      );

      setState(() {
        employeesMap = {for (var e in employees) e.id: e};
        workTimesMap = {for (var w in workTimes) w.id: w};
      });

      // Load lịch sử chấm công
      await _loadAttendanceHistories();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Tải lịch sử chấm công (với filter nếu có)
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

  // Hiển thị dialog chọn khoảng thời gian
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

  // Xóa tất cả bộ lọc
  void _clearFilters() {
    setState(() {
      // Chỉ xóa filter nhân viên nếu user có quyền chọn
      if (_canSelectEmployee) {
        _selectedEmployeeId = null;
      }
      _startDate = null;
      _endDate = null;
    });
    _loadAttendanceHistories();
  }

  // Chuyển enum loại chấm công sang text tiếng Việt
  String _getTypeText(AttendanceType type) {
    switch (type) {
      case AttendanceType.checkIn:
        return 'Vào';
      case AttendanceType.checkOut:
        return 'Ra';
    }
  }

  // Chuyển enum trạng thái sang text tiếng Việt
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

  // Màu sắc cho từng trạng thái
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

  // Màu sắc cho từng loại chấm công
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
    // Kiểm tra xem màn này có nằm trong Scaffold cha không (vd: HomeScreen có AppBar riêng)
    // Nếu có thì không render AppBar để tránh trùng lặp title
    // Nếu không thì render đầy đủ Scaffold với AppBar và actions
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    // Nội dung chính: filter chips (nếu có) + danh sách lịch sử
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
      // Nếu đã có Scaffold cha: chỉ hiển thị nội dung + floating buttons
      // Dùng Stack để đặt 2 FAB (filter + thêm mới) ở góc phải dưới
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
                  // Nút lọc (nhỏ)
                  FloatingActionButton(
                    heroTag: 'filter_btn',
                    mini: true,
                    onPressed: _showFilterDialog,
                    child: const Icon(Icons.filter_alt),
                  ),
                  const SizedBox(height: 8),
                  // Nút thêm bản ghi chấm công mới
                  FloatingActionButton(
                    heroTag: 'add_btn',
                    onPressed: () async {
                      final result = await context.push<bool>(
                        '/attendance/new',
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

    // Nếu không có Scaffold cha: render đầy đủ với AppBar

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chấm công'),
        actions: [
          // Nút lọc trên AppBar
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
          // Nút thêm mới trên AppBar
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.push<bool>('/attendance/new');
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

  // Hiển thị các chip filter đang được áp dụng (có nút xóa từng filter)
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Wrap(
        spacing: 8,
        children: [
          // Chip hiển thị nhân viên đang được lọc (nếu có)
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
          // Chip hiển thị khoảng thời gian đang được lọc (nếu có)
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
          // Nút xóa tất cả filter
          TextButton.icon(
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Xóa lọc'),
            onPressed: _clearFilters,
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog để chọn bộ lọc
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc dữ liệu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown chọn nhân viên (chỉ hiện nếu user có quyền)
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
            // ListTile để chọn khoảng thời gian (tap để mở date range picker)
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
          // Nút xóa tất cả filter
          TextButton(
            onPressed: () {
              _clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Xóa lọc'),
          ),
          // Nút áp dụng filter và tải lại dữ liệu
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

  // Render body chính: loading / error / empty / danh sách
  Widget _buildBody() {
    // Đang tải dữ liệu
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Có lỗi
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

    // Không có dữ liệu
    if (attendanceHistories.isEmpty) {
      return const Center(child: Text('Không có lịch sử chấm công nào'));
    }

    // Hiển thị danh sách (với RefreshIndicator để kéo xuống làm mới)
    return RefreshIndicator(
      onRefresh: _loadAttendanceHistories,
      child: ListView.builder(
        itemCount: attendanceHistories.length,
        itemBuilder: (context, index) {
          final history = attendanceHistories[index];
          final employee = employeesMap[history.employeeId];
          final workTime = workTimesMap[history.workTimeId];

          // Card cho mỗi bản ghi chấm công
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              // Icon loại chấm công (vào = login, ra = logout)
              leading: CircleAvatar(
                backgroundColor: _getTypeColor(history.type),
                child: Icon(
                  history.type == AttendanceType.checkIn
                      ? Icons.login
                      : Icons.logout,
                  color: Colors.white,
                ),
              ),
              // Tiêu đề: Tên ca làm việc + Loại (Vào/Ra)
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
              // Thông tin chi tiết: tên nhân viên, ngày giờ, trạng thái
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên nhân viên
                  Text(
                    employee?.fullName ?? 'Unknown Employee',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Ngày giờ chấm công
                  Text(_dateFormat.format(history.attendanceDate)),
                  const SizedBox(height: 4),
                  // Badge trạng thái (đúng giờ/trễ/sớm)
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
