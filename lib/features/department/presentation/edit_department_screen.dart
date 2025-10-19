import 'package:flutter/material.dart';
import '../data/datasources/department_remote_datasource.dart';

class EditDepartmentScreen extends StatefulWidget {
  final String? departmentId;

  const EditDepartmentScreen({
    super.key,
    this.departmentId,
  });

  @override
  State<EditDepartmentScreen> createState() => _EditDepartmentScreenState();
}

class _EditDepartmentScreenState extends State<EditDepartmentScreen> {
  final DepartmentRemoteDataSource _dataSource = DepartmentRemoteDataSourceImpl();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool isLoading = false;
  bool isLoadingData = true;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.departmentId != null) {
      _loadDepartment();
    } else {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  Future<void> _loadDepartment() async {
    if (widget.departmentId == null) return;
    
    try {
      // Note: API doesn't have get detail endpoint for department, so we'll use mock data
      // In real app, would call _dataSource.getDepartmentDetail(widget.departmentId!)
      setState(() {
        _nameController.text = 'Department ${widget.departmentId}';
        _descriptionController.text = 'Description for department ${widget.departmentId}';
        isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateDepartment() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.departmentId == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
      };
      
      await _dataSource.updateDepartment(widget.departmentId!, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật phòng ban thành công')),
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
        title: const Text('Chỉnh sửa phòng ban'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _updateDepartment,
            child: const Text('Lưu'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
                onPressed: isLoading ? null : _updateDepartment,
                child: isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cập nhật phòng ban'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
