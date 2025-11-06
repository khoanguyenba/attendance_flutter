// Màn: Tạo tài khoản cho nhân viên
// File này cho phép tạo tài khoản đăng nhập cho nhân viên đã có trong hệ thống
// Input: employeeId (ID nhân viên cần tạo tài khoản)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../domain/usecases/create_user_usecase.dart';
import '../../employee/domain/usecases/get_employee_by_id_usecase.dart';
import '../../employee/domain/entities/app_employee.dart';
import '../../department/domain/usecases/get_department_by_id_usecase.dart';
import '../../department/domain/entities/app_department.dart';

// Widget chính cho màn tạo tài khoản
// Nhận employeeId để biết tạo tài khoản cho nhân viên nào
class CreateUserScreen extends StatefulWidget {
  final String employeeId; // ID nhân viên cần tạo tài khoản

  const CreateUserScreen({super.key, required this.employeeId});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  // Form key để quản lý validation
  final _formKey = GlobalKey<FormState>();
  // Controller cho các trường nhập liệu
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // UseCase để tạo user, lấy thông tin employee và department
  late final CreateUserUseCase _createUserUseCase;
  late final GetEmployeeByIdUseCase _getEmployeeByIdUseCase;
  late final GetDepartmentByIdUseCase _getDepartmentByIdUseCase;

  // Trạng thái loading và hiển thị/ẩn password
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Thông tin nhân viên để hiển thị (mã NV, tên, phòng ban)
  String? _employeeCode;
  String? _employeeName;
  String? _departmentName;

  @override
  void initState() {
    super.initState();
    // Lấy các UseCase từ DI
    _createUserUseCase = resolve<CreateUserUseCase>();
    _getEmployeeByIdUseCase = resolve<GetEmployeeByIdUseCase>();
    _getDepartmentByIdUseCase = resolve<GetDepartmentByIdUseCase>();
    // Tải thông tin nhân viên để hiển thị
    _loadDisplayInfo();
  }

  // Tải thông tin nhân viên (mã, tên, phòng ban) để hiển thị trong UI
  Future<void> _loadDisplayInfo() async {
    try {
      final AppEmployee? emp = await _getEmployeeByIdUseCase.call(
        widget.employeeId,
      );
      if (emp != null) {
        _employeeCode = emp.code;
        _employeeName = emp.fullName;
        // Lấy tên phòng ban (nếu có)
        try {
          final AppDepartment? dept = await _getDepartmentByIdUseCase.call(
            emp.departmentId,
          );
          _departmentName = dept?.name;
        } catch (_) {}
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Xử lý tạo tài khoản khi người dùng nhấn nút
  Future<void> _handleCreateUser() async {
    // Validate form trước
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi usecase để tạo tài khoản
      await _createUserUseCase.call(
        _userNameController.text.trim(),
        _passwordController.text,
        widget.employeeId,
      );

      if (mounted) {
        // Thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo tài khoản thành công'),
            backgroundColor: Colors.green,
          ),
        );
        // Quay lại và trả về true để màn trước reload
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        // Hiện thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card hiển thị thông tin nhân viên
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin nhân viên',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_employeeCode != null) Text('Mã NV: $_employeeCode'),
                      if (_employeeName != null) Text('Tên: $_employeeName'),
                      if (_departmentName != null)
                        Text('Phòng ban: $_departmentName'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Trường nhập tên đăng nhập
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                  hintText: 'Nhập tên đăng nhập',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  if (value.trim().length < 3) {
                    return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Trường nhập mật khẩu (có nút show/hide)
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Trường xác nhận mật khẩu
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  hintText: 'Nhập lại mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Nút tạo tài khoản (hiện loading khi đang xử lý)
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Tạo tài khoản'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
