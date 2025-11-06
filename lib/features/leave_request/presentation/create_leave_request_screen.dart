// Màn: Tạo đơn nghỉ phép
// File này cho phép tạo đơn nghỉ phép mới
// - Admin/Manager: có thể chọn nhân viên
// - User thường: tự động lấy nhân viên của user hiện tại
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../domain/usecases/create_leave_request_usecase.dart';
import '../../employee/domain/entities/app_employee.dart';
import '../../employee/domain/usecases/get_page_employee_usecase.dart';
import '../../user/domain/usecases/get_current_user_usecase.dart';
import '../../user/domain/entities/app_user.dart';

// Widget chính cho màn tạo đơn nghỉ phép
class CreateLeaveRequestScreen extends StatefulWidget {
  const CreateLeaveRequestScreen({super.key});

  @override
  State<CreateLeaveRequestScreen> createState() =>
      _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState extends State<CreateLeaveRequestScreen> {
  // UseCase để tạo đơn, lấy danh sách nhân viên, và lấy user hiện tại
  late final CreateLeaveRequestUseCase _createUseCase;
  late final GetPageEmployeeUseCase _getEmployeesUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  // Form key và controller
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  // Dữ liệu form: danh sách nhân viên, nhân viên được chọn, ngày bắt đầu/kết thúc
  List<AppEmployee> _employees = [];
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;

  // Thông tin user hiện tại và quyền
  AppUser? _currentUser;
  bool _canSelectEmployee = false; // true nếu admin/manager

  // Trạng thái
  bool isLoading = false;
  bool isLoadingData = false;
  String? error;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Lấy UseCase từ DI
    _createUseCase = resolve<CreateLeaveRequestUseCase>();
    _getEmployeesUseCase = resolve<GetPageEmployeeUseCase>();
    _getCurrentUserUseCase = resolve<GetCurrentUserUseCase>();

    // Tải dữ liệu ban đầu
    _loadInitialData();
  }

  // Tải dữ liệu ban đầu: user hiện tại và danh sách nhân viên (nếu cần)
  Future<void> _loadInitialData() async {
    setState(() {
      isLoadingData = true;
    });

    try {
      // Load user hiện tại để kiểm tra quyền
      final currentUser = await _getCurrentUserUseCase.call();

      if (currentUser != null) {
        _currentUser = currentUser;

        // Kiểm tra xem user có phải admin/manager không
        final role = currentUser.role.toLowerCase();
        _canSelectEmployee = role == 'admin' || role == 'manager';

        // Nếu không phải admin/manager, tự động set employeeId
        if (!_canSelectEmployee) {
          _selectedEmployeeId = currentUser.employeeId;
        }
      }

      // Load danh sách nhân viên (chỉ khi user có quyền chọn)
      if (_canSelectEmployee) {
        await _loadEmployees();
      }
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

  // Tải danh sách nhân viên
  Future<void> _loadEmployees() async {
    try {
      final employees = await _getEmployeesUseCase.call(
        pageIndex: 1,
        pageSize: 1000,
      );

      setState(() {
        _employees = employees;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  int? _calculateDays() {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays + 1;
    }
    return null;
  }

  Future<void> _createLeaveRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn nhân viên')));
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu')),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày kết thúc')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await _createUseCase.call(
        employeeId: _selectedEmployeeId!,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo đơn nghỉ phép thành công')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn nghỉ phép'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _createLeaveRequest,
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
            if (_canSelectEmployee)
              DropdownButtonFormField<String>(
                initialValue: _selectedEmployeeId,
                decoration: InputDecoration(
                  labelText: 'Nhân viên *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                items: _employees.map((employee) {
                  return DropdownMenuItem(
                    value: employee.id,
                    child: Text(employee.fullName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmployeeId = value;
                  });
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Người xin nghỉ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.userName ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Thời gian nghỉ phép',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Từ ngày *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                        ),
                      ),
                      child: Text(
                        _startDate != null
                            ? _dateFormat.format(_startDate!)
                            : 'Chọn ngày',
                        style: TextStyle(
                          fontSize: 16,
                          color: _startDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Đến ngày *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.orange,
                        ),
                      ),
                      child: Text(
                        _endDate != null
                            ? _dateFormat.format(_endDate!)
                            : 'Chọn ngày',
                        style: TextStyle(
                          fontSize: 16,
                          color: _endDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_calculateDays() != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tổng số ngày nghỉ: ${_calculateDays()} ngày',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập lý do nghỉ phép';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Lý do nghỉ phép *',
                hintText: 'Nhập lý do xin nghỉ phép...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Đơn nghỉ phép sẽ được gửi đến người duyệt. Trạng thái ban đầu là "Chờ duyệt".',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _createLeaveRequest,
                icon: const Icon(Icons.send),
                label: const Text('Gửi đơn nghỉ phép'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
