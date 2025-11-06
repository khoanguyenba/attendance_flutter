// Màn: Tạo/Sửa phòng ban
// File này cho phép tạo mới hoặc chỉnh sửa thông tin phòng ban
// Mode: departmentId == null => tạo mới, departmentId != null => sửa
import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../domain/usecases/create_department_usecase.dart';
import '../domain/usecases/update_department_usecase.dart';
import '../domain/usecases/get_department_by_id_usecase.dart';

// Widget chính cho màn tạo/sửa phòng ban
class EditDepartmentScreen extends StatefulWidget {
  final String? departmentId; // null = tạo mới, !null = sửa

  const EditDepartmentScreen({super.key, this.departmentId});

  @override
  State<EditDepartmentScreen> createState() => _EditDepartmentScreenState();
}

class _EditDepartmentScreenState extends State<EditDepartmentScreen> {
  // UseCase để tạo, cập nhật, và lấy phòng ban
  late final CreateDepartmentUseCase _createUseCase;
  late final UpdateDepartmentUseCase _updateUseCase;
  late final GetDepartmentByIdUseCase _getByIdUseCase;

  // Form key và controller cho input
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Trạng thái loading và error
  bool isLoading = false;
  String? error;

  // Kiểm tra xem đang ở chế độ sửa hay tạo
  bool get isEditMode => widget.departmentId != null;

  @override
  void initState() {
    super.initState();
    // Lấy UseCase từ DI
    _createUseCase = resolve<CreateDepartmentUseCase>();
    _updateUseCase = resolve<UpdateDepartmentUseCase>();
    _getByIdUseCase = resolve<GetDepartmentByIdUseCase>();

    // Nếu là chế độ sửa, tải dữ liệu phòng ban
    if (isEditMode) {
      _loadDepartment();
    }
  }

  // Tải thông tin phòng ban khi ở chế độ sửa
  Future<void> _loadDepartment() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final department = await _getByIdUseCase.call(widget.departmentId!);
      if (department != null) {
        // Điền dữ liệu vào form
        _codeController.text = department.code;
        _nameController.text = department.name;
        _descriptionController.text = department.description ?? '';
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
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Lưu phòng ban (tạo mới hoặc cập nhật)
  Future<void> _saveDepartment() async {
    // Validate form trước
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (isEditMode) {
        // Cập nhật phòng ban đã tồn tại
        await _updateUseCase.call(
          id: widget.departmentId!,
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        );
      } else {
        // Tạo phòng ban mới
        await _createUseCase.call(
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        );
      }

      if (mounted) {
        // Hiện thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Cập nhật phòng ban thành công'
                  : 'Tạo phòng ban thành công',
            ),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa phòng ban' : 'Tạo phòng ban mới'),
        actions: [
          // Nút Lưu ở AppBar
          TextButton(
            onPressed: isLoading ? null : _saveDepartment,
            child: const Text('Lưu'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Hiển thị loading khi đang tải dữ liệu trong chế độ sửa
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
            // Hiển thị thông báo lỗi (nếu có)
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
            // Trường nhập mã phòng ban
            TextFormField(
              controller: _codeController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã phòng ban';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Mã phòng ban *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Trường nhập tên phòng ban
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên phòng ban';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Tên phòng ban *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Trường nhập mô tả (optional, nhiều dòng)
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Nút lưu ở cuối form
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveDepartment,
                child: Text(
                  isEditMode ? 'Cập nhật phòng ban' : 'Tạo phòng ban',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
