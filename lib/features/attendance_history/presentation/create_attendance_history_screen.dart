// Màn: Chấm công
// File này cho phép tạo bản ghi chấm công mới (vào/ra)
// User chọn ca làm việc, loại chấm công, và trạng thái
import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/attendance_history.dart';
import '../domain/usecases/create_attendance_history_usecase.dart';
import '../../worktime/domain/entities/app_work_time.dart';
import '../../worktime/domain/usecases/get_page_work_time_usecase.dart';

// Widget chính cho màn chấm công
class CreateAttendanceHistoryScreen extends StatefulWidget {
  const CreateAttendanceHistoryScreen({super.key});

  @override
  State<CreateAttendanceHistoryScreen> createState() =>
      _CreateAttendanceHistoryScreenState();
}

class _CreateAttendanceHistoryScreenState
    extends State<CreateAttendanceHistoryScreen> {
  // UseCase để tạo bản ghi chấm công và lấy danh sách ca làm việc
  late final CreateAttendanceHistoryUseCase _createUseCase;
  late final GetPageWorkTimeUseCase _getWorkTimesUseCase;

  final _formKey = GlobalKey<FormState>();

  // Trạng thái
  bool isLoading = false;
  bool isLoadingData = false;
  String? error;

  // Dữ liệu form: loại chấm công, trạng thái, ca làm việc
  AttendanceType _selectedType = AttendanceType.checkIn;
  AttendanceStatus _selectedStatus = AttendanceStatus.onTime;
  String? _selectedWorkTimeId;

  // Danh sách ca làm việc
  List<AppWorkTime> _workTimes = [];

  @override
  void initState() {
    super.initState();
    // Lấy UseCase từ DI
    _createUseCase = resolve<CreateAttendanceHistoryUseCase>();
    _getWorkTimesUseCase = resolve<GetPageWorkTimeUseCase>();

    // Tải danh sách ca làm việc
    _loadWorkTimes();
  }

  // Tải danh sách ca làm việc (chỉ lấy ca đang hoạt động)
  Future<void> _loadWorkTimes() async {
    setState(() {
      isLoadingData = true;
    });

    try {
      final workTimes = await _getWorkTimesUseCase.execute(
        pageIndex: 1,
        pageSize: 100,
        isActive: true, // Chỉ lấy ca đang hoạt động
      );

      setState(() {
        _workTimes = workTimes;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  // Tạo bản ghi chấm công
  Future<void> _createAttendanceHistory() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra đã chọn ca làm việc
    if (_selectedWorkTimeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ca làm việc')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Gọi usecase để tạo bản ghi chấm công
      await _createUseCase.call(
        type: _selectedType,
        status: _selectedStatus,
        workTimeId: _selectedWorkTimeId!,
      );

      if (mounted) {
        // Hiện thông báo thành công
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chấm công thành công')));
        // Quay lại và trả về true
        Navigator.pop(context, true);
      }
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

  // Icon cho từng loại chấm công
  IconData _getTypeIcon(AttendanceType type) {
    switch (type) {
      case AttendanceType.checkIn:
        return Icons.login;
      case AttendanceType.checkOut:
        return Icons.logout;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm công'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _createAttendanceHistory,
            child: const Text('Lưu'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lỗi: $error',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            DropdownButtonFormField<String>(
              initialValue: _selectedWorkTimeId,
              decoration: InputDecoration(
                labelText: 'Ca làm việc *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.access_time),
              ),
              items: _workTimes.map((workTime) {
                return DropdownMenuItem(
                  value: workTime.id,
                  child: Text(workTime.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWorkTimeId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn ca làm việc';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Loại chấm công',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...AttendanceType.values.map((type) {
              return RadioListTile<AttendanceType>(
                title: Row(
                  children: [
                    Icon(_getTypeIcon(type)),
                    const SizedBox(width: 8),
                    Text(_getTypeText(type)),
                  ],
                ),
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                activeColor: type == AttendanceType.checkIn
                    ? Colors.blue
                    : Colors.purple,
              );
            }),
            const SizedBox(height: 24),
            const Text(
              'Trạng thái',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AttendanceStatus>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Trạng thái *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: AttendanceStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _createAttendanceHistory,
                icon: Icon(_getTypeIcon(_selectedType)),
                label: Text(
                  'Chấm công ${_getTypeText(_selectedType)}',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == AttendanceType.checkIn
                      ? Colors.blue
                      : Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
