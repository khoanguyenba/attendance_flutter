import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/entities/attendance.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<Attendance> attendanceHistory = [];
  bool isLoading = false;
  String? error;
  String employeeId = 'mock-employee-id'; // TODO: Get from auth

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  int? selectedYear;
  int? selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // TODO: Implement actual API call
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        attendanceHistory = [
          Attendance(
            id: '1',
            employeeId: employeeId,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            checkInTime: DateTime.now().subtract(const Duration(days: 1, hours: -8)),
            checkOutTime: DateTime.now().subtract(const Duration(days: 1, hours: -17)),
            checkInStatus: 0,
            checkOutStatus: 0,
          ),
          Attendance(
            id: '2',
            employeeId: employeeId,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            checkInTime: DateTime.now().subtract(const Duration(days: 2, hours: -8, minutes: -15)),
            checkOutTime: DateTime.now().subtract(const Duration(days: 2, hours: -17)),
            checkInStatus: 1, // Late
            checkOutStatus: 0,
          ),
          Attendance(
            id: '3',
            employeeId: employeeId,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            checkInTime: DateTime.now().subtract(const Duration(days: 3, hours: -7, minutes: -45)),
            checkOutTime: DateTime.now().subtract(const Duration(days: 3, hours: -16, minutes: -30)),
            checkInStatus: 2, // Early
            checkOutStatus: 2, // Early
          ),
        ];
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

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedFromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedFromDate) {
      setState(() {
        selectedFromDate = picked;
        selectedToDate = null; // Reset to date when from date changes
      });
      _loadAttendanceHistory();
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedToDate ?? selectedFromDate ?? DateTime.now(),
      firstDate: selectedFromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedToDate) {
      setState(() {
        selectedToDate = picked;
      });
      _loadAttendanceHistory();
    }
  }

  void _selectYear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn năm'),
        content: SizedBox(
          width: 200,
          height: 300,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              final year = DateTime.now().year - index;
              return ListTile(
                title: Text(year.toString()),
                selected: selectedYear == year,
                onTap: () {
                  setState(() {
                    selectedYear = year;
                    selectedFromDate = null;
                    selectedToDate = null;
                  });
                  Navigator.pop(context);
                  _loadAttendanceHistory();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectMonth() {
    if (selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn năm trước')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn tháng'),
        content: SizedBox(
          width: 200,
          height: 300,
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              return ListTile(
                title: Text('Tháng $month'),
                selected: selectedMonth == month,
                onTap: () {
                  setState(() {
                    selectedMonth = month;
                    selectedFromDate = null;
                    selectedToDate = null;
                  });
                  Navigator.pop(context);
                  _loadAttendanceHistory();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedFromDate = null;
      selectedToDate = null;
      selectedYear = null;
      selectedMonth = null;
    });
    _loadAttendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chấm công'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
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
              onPressed: _loadAttendanceHistory,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (attendanceHistory.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu chấm công'),
      );
    }

    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAttendanceHistory,
            child: ListView.builder(
              itemCount: attendanceHistory.length,
              itemBuilder: (context, index) {
                final attendance = attendanceHistory[index];
                return _buildAttendanceCard(attendance);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          if (selectedFromDate != null)
            Chip(
              label: Text('Từ: ${DateFormat('dd/MM/yyyy').format(selectedFromDate!)}'),
              onDeleted: () {
                setState(() {
                  selectedFromDate = null;
                });
                _loadAttendanceHistory();
              },
            ),
          if (selectedToDate != null)
            Chip(
              label: Text('Đến: ${DateFormat('dd/MM/yyyy').format(selectedToDate!)}'),
              onDeleted: () {
                setState(() {
                  selectedToDate = null;
                });
                _loadAttendanceHistory();
              },
            ),
          if (selectedYear != null)
            Chip(
              label: Text('Năm: $selectedYear'),
              onDeleted: () {
                setState(() {
                  selectedYear = null;
                  selectedMonth = null;
                });
                _loadAttendanceHistory();
              },
            ),
          if (selectedMonth != null)
            Chip(
              label: Text('Tháng: $selectedMonth'),
              onDeleted: () {
                setState(() {
                  selectedMonth = null;
                });
                _loadAttendanceHistory();
              },
            ),
          if (selectedFromDate != null || selectedToDate != null || selectedYear != null || selectedMonth != null)
            Chip(
              label: const Text('Xóa bộ lọc'),
              onDeleted: _clearFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(attendance.createdAt),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (attendance.checkInTime != null)
              _buildTimeRow(
                'Check In',
                DateFormat('HH:mm:ss').format(attendance.checkInTime!),
                attendance.checkInStatus,
              ),
            if (attendance.checkOutTime != null)
              _buildTimeRow(
                'Check Out',
                DateFormat('HH:mm:ss').format(attendance.checkOutTime!),
                attendance.checkOutStatus,
              ),
            if (attendance.checkInTime == null && attendance.checkOutTime == null)
              const Text(
                'Chưa chấm công',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String time, int? status) {
    Color statusColor = Colors.green;
    String statusText = 'Đúng giờ';

    if (status != null) {
      switch (status) {
        case 1:
          statusColor = Colors.orange;
          statusText = 'Muộn';
          break;
        case 2:
          statusColor = Colors.blue;
          statusText = 'Sớm';
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(time),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bộ lọc'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Khoảng thời gian'),
              subtitle: Text(
                selectedFromDate != null && selectedToDate != null
                    ? '${DateFormat('dd/MM/yyyy').format(selectedFromDate!)} - ${DateFormat('dd/MM/yyyy').format(selectedToDate!)}'
                    : 'Chọn khoảng thời gian',
              ),
              onTap: () {
                Navigator.pop(context);
                _selectFromDate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Năm'),
              subtitle: Text(selectedYear?.toString() ?? 'Chọn năm'),
              onTap: () {
                Navigator.pop(context);
                _selectYear();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Tháng'),
              subtitle: Text(selectedMonth?.toString() ?? 'Chọn tháng'),
              onTap: () {
                Navigator.pop(context);
                _selectMonth();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearFilters();
            },
            child: const Text('Xóa bộ lọc'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
