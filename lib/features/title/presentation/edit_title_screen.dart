import 'package:flutter/material.dart';
import '../data/datasources/title_remote_datasource.dart';

class EditTitleScreen extends StatefulWidget {
  final String? titleId;

  const EditTitleScreen({
    super.key,
    this.titleId,
  });

  @override
  State<EditTitleScreen> createState() => _EditTitleScreenState();
}

class _EditTitleScreenState extends State<EditTitleScreen> {
  final TitleRemoteDataSource _dataSource = TitleRemoteDataSourceImpl();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool isLoading = false;
  bool isLoadingData = true;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.titleId != null) {
      _loadTitle();
    } else {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  Future<void> _loadTitle() async {
    if (widget.titleId == null) return;
    
    try {
      // Note: API doesn't have get detail endpoint for title, so we'll use mock data
      // In real app, would call _dataSource.getTitleDetail(widget.titleId!)
      setState(() {
        _nameController.text = 'Title ${widget.titleId}';
        _descriptionController.text = 'Description for title ${widget.titleId}';
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

  Future<void> _updateTitle() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.titleId == null) return;

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
      
      await _dataSource.updateTitle(widget.titleId!, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật chức vụ thành công')),
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
        title: const Text('Chỉnh sửa chức vụ'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _updateTitle,
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
                  return 'Vui lòng nhập tên chức vụ';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Tên chức vụ *',
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
                onPressed: isLoading ? null : _updateTitle,
                child: isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cập nhật chức vụ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
