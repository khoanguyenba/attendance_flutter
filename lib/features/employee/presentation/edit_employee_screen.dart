import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../domain/entities/app_employee.dart';
import '../domain/usecases/create_employee_usecase.dart';
import '../domain/usecases/update_employee_usecase.dart';
import '../domain/usecases/get_employee_by_id_usecase.dart';
import '../domain/usecases/get_page_employee_usecase.dart';
import '../../department/domain/entities/app_department.dart';
import '../../department/domain/usecases/get_page_department_usecase.dart';

class EditEmployeeScreen extends StatefulWidget {
  final String? employeeId; // null = create mode, not null = edit mode

  const EditEmployeeScreen({super.key, this.employeeId});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  late final CreateEmployeeUseCase _createUseCase;
  late final UpdateEmployeeUseCase _updateUseCase;
  late final GetEmployeeByIdUseCase _getByIdUseCase;
  late final GetPageEmployeeUseCase _getPageEmployeeUseCase;
  late final GetPageDepartmentUseCase _getDepartmentsUseCase;

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool isLoading = false;
  String? error;

  Gender? _selectedGender;
  EmployeeStatus _selectedStatus = EmployeeStatus.active;
  String? _selectedDepartmentId;
  String? _selectedManagerId;

  List<AppDepartment> _departments = [];
  List<AppEmployee> _employees = [];

  bool get isEditMode => widget.employeeId != null;

  @override
  void initState() {
    super.initState();
    _createUseCase = resolve<CreateEmployeeUseCase>();
    _updateUseCase = resolve<UpdateEmployeeUseCase>();
    _getByIdUseCase = resolve<GetEmployeeByIdUseCase>();
    _getPageEmployeeUseCase = resolve<GetPageEmployeeUseCase>();
    _getDepartmentsUseCase = resolve<GetPageDepartmentUseCase>();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load departments
      final departments = await _getDepartmentsUseCase.call(
        pageIndex: 1,
        pageSize: 100,
      );

      // Load employees for manager selection
      final employees = await _getPageEmployeeUseCase.call(
        pageIndex: 1,
        pageSize: 100,
      );

      setState(() {
        _departments = departments;
        _employees = employees;
      });

      // If edit mode, load employee data
      if (isEditMode) {
        await _loadEmployee();
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

  Future<void> _loadEmployee() async {
    try {
      final employee = await _getByIdUseCase.call(widget.employeeId!);
      if (employee != null) {
        _codeController.text = employee.code;
        _fullNameController.text = employee.fullName;
        _emailController.text = employee.email;
        setState(() {
          _selectedGender = employee.gender;
          _selectedStatus = employee.status;
          _selectedDepartmentId = employee.departmentId;
          _selectedManagerId = employee.managerId;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn giới tính')));
      return;
    }

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phòng ban')));
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (isEditMode) {
        // Update existing employee
        await _updateUseCase.call(
          id: widget.employeeId!,
          code: _codeController.text,
          fullName: _fullNameController.text,
          email: _emailController.text,
          gender: _selectedGender!,
          departmentId: _selectedDepartmentId!,
          status: _selectedStatus,
          managerId: _selectedManagerId,
        );
      } else {
        // Create new employee
        await _createUseCase.call(
          code: _codeController.text,
          fullName: _fullNameController.text,
          email: _emailController.text,
          gender: _selectedGender!,
          departmentId: _selectedDepartmentId!,
          status: _selectedStatus,
          managerId: _selectedManagerId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Cập nhật nhân viên thành công'
                  : 'Tạo nhân viên thành công',
            ),
          ),
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

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Nam';
      case Gender.female:
        return 'Nữ';
    }
  }

  String _getStatusText(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return 'Đang làm việc';
      case EmployeeStatus.inactive:
        return 'Tạm nghỉ';
      case EmployeeStatus.suspended:
        return 'Đã nghỉ việc';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa nhân viên' : 'Tạo nhân viên mới'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveEmployee,
            child: const Text('Lưu'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading && isEditMode) {
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
            TextFormField(
              controller: _codeController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã nhân viên';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Mã nhân viên *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Họ và tên *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@')) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Gender>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Giới tính *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: Gender.values.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(_getGenderText(gender)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDepartmentId,
              decoration: InputDecoration(
                labelText: 'Phòng ban *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _departments.map((department) {
                return DropdownMenuItem(
                  value: department.id,
                  child: Text(department.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartmentId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EmployeeStatus>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Trạng thái *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: EmployeeStatus.values.map((status) {
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedManagerId,
              decoration: InputDecoration(
                labelText: 'Quản lý (tùy chọn)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('-- Không có --'),
                ),
                ..._employees
                    .where(
                      (e) => e.id != widget.employeeId,
                    ) // Exclude self in edit mode
                    .map((employee) {
                      return DropdownMenuItem(
                        value: employee.id,
                        child: Text(employee.fullName),
                      );
                    })
                    ,
              ],
              onChanged: (value) {
                setState(() {
                  _selectedManagerId = value;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveEmployee,
                child: Text(
                  isEditMode ? 'Cập nhật nhân viên' : 'Tạo nhân viên',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
