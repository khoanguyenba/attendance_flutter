import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/employee.dart';

class EditEmployeeScreen extends StatefulWidget {
  final String? employeeId;

  const EditEmployeeScreen({
    super.key,
    this.employeeId,
  });

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _codeController = TextEditingController();

  int? _selectedGender;
  DateTime? _selectedBirthDate;
  String? _selectedDepartmentId;
  String? _selectedTitleId;

  List<EmployeeBasicInfo> departments = [];
  List<EmployeeBasicInfo> titles = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    // TODO: Load employee data from API
    _fullNameController.text = 'Nguyễn Văn A';
    _codeController.text = 'NV001';
    _selectedGender = 1;
    _selectedBirthDate = DateTime(1990, 5, 15);
    _selectedDepartmentId = 'dept1';
    _selectedTitleId = 'title1';
  }

  Future<void> _loadDropdownData() async {
    // TODO: Load departments and titles from their respective features
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật nhân viên thành công')),
        );
        context.pop(true);
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
        title: const Text('Chỉnh sửa nhân viên'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _updateEmployee,
            child: const Text('Lưu'),
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
            _buildTextField(
              controller: _fullNameController,
              label: 'Họ và tên *',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _codeController,
              label: 'Mã nhân viên *',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã nhân viên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            _buildBirthDateField(),
            const SizedBox(height: 16),
            _buildDepartmentDropdown(),
            const SizedBox(height: 16),
            _buildTitleDropdown(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateEmployee,
                child: const Text('Cập nhật nhân viên'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Nam')),
        DropdownMenuItem(value: 1, child: Text('Nữ')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ngày sinh',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _selectedBirthDate != null
              ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
              : 'Chọn ngày sinh',
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartmentId,
      decoration: InputDecoration(
        labelText: 'Phòng ban',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: departments.map((dept) {
        return DropdownMenuItem(
          value: dept.id,
          child: Text(dept.fullName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDepartmentId = value;
        });
      },
    );
  }

  Widget _buildTitleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedTitleId,
      decoration: InputDecoration(
        labelText: 'Chức vụ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: titles.map((title) {
        return DropdownMenuItem(
          value: title.id,
          child: Text(title.fullName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTitleId = value;
        });
      },
    );
  }
}
