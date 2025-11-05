import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../domain/usecases/create_department_usecase.dart';
import '../domain/usecases/update_department_usecase.dart';
import '../domain/usecases/get_department_by_id_usecase.dart';

class EditDepartmentScreen extends StatefulWidget {
  final String? departmentId; // null = create mode, not null = edit mode
  
  const EditDepartmentScreen({
    super.key,
    this.departmentId,
  });

  @override
  State<EditDepartmentScreen> createState() => _EditDepartmentScreenState();
}

class _EditDepartmentScreenState extends State<EditDepartmentScreen> {
  late final CreateDepartmentUseCase _createUseCase;
  late final UpdateDepartmentUseCase _updateUseCase;
  late final GetDepartmentByIdUseCase _getByIdUseCase;
  
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool isLoading = false;
  String? error;
  
  bool get isEditMode => widget.departmentId != null;

  @override
  void initState() {
    super.initState();
    _createUseCase = resolve<CreateDepartmentUseCase>();
    _updateUseCase = resolve<UpdateDepartmentUseCase>();
    _getByIdUseCase = resolve<GetDepartmentByIdUseCase>();
    
    if (isEditMode) {
      _loadDepartment();
    }
  }
  
  Future<void> _loadDepartment() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final department = await _getByIdUseCase.call(widget.departmentId!);
      if (department != null) {
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

  Future<void> _saveDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (isEditMode) {
        // Update existing department
        await _updateUseCase.call(
          id: widget.departmentId!,
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty 
              ? _descriptionController.text 
              : null,
        );
      } else {
        // Create new department
        await _createUseCase.call(
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty 
              ? _descriptionController.text 
              : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode 
                ? 'Cập nhật phòng ban thành công' 
                : 'Tạo phòng ban thành công'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa phòng ban' : 'Tạo phòng ban mới'),
        actions: [
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveDepartment,
                child: Text(isEditMode ? 'Cập nhật phòng ban' : 'Tạo phòng ban'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}