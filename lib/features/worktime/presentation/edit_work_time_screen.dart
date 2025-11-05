import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../domain/usecases/create_work_time_usecase.dart';
import '../domain/usecases/update_work_time_usecase.dart';
import '../domain/usecases/get_work_time_by_id_usecase.dart';

class EditWorkTimeScreen extends StatefulWidget {
  final String? workTimeId; // null = create mode, not null = edit mode
  
  const EditWorkTimeScreen({
    super.key,
    this.workTimeId,
  });

  @override
  State<EditWorkTimeScreen> createState() => _EditWorkTimeScreenState();
}

class _EditWorkTimeScreenState extends State<EditWorkTimeScreen> {
  late final CreateWorkTimeUseCase _createUseCase;
  late final UpdateWorkTimeUseCase _updateUseCase;
  late final GetWorkTimeByIdUseCase _getByIdUseCase;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  bool _isActive = true;

  bool isLoading = false;
  String? error;
  
  bool get isEditMode => widget.workTimeId != null;

  @override
  void initState() {
    super.initState();
    _createUseCase = resolve<CreateWorkTimeUseCase>();
    _updateUseCase = resolve<UpdateWorkTimeUseCase>();
    _getByIdUseCase = resolve<GetWorkTimeByIdUseCase>();
    
    if (isEditMode) {
      _loadWorkTime();
    }
  }
  
  Future<void> _loadWorkTime() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final workTime = await _getByIdUseCase.execute(widget.workTimeId!);
      if (workTime != null) {
        _nameController.text = workTime.name;
        setState(() {
          _isActive = workTime.isActive;
          _checkInTime = _parseTimeString(workTime.validCheckInTime);
          _checkOutTime = _parseTimeString(workTime.validCheckOutTime);
        });
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

  TimeOfDay _parseTimeString(String timeString) {
    // Format: HH:mm:ss
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    // Format to HH:mm:ss
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String _displayTime(TimeOfDay? time) {
    if (time == null) return 'Chưa chọn';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _checkInTime = picked;
      });
    }
  }

  Future<void> _selectCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime ?? const TimeOfDay(hour: 17, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _checkOutTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkTime() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_checkInTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ vào')),
      );
      return;
    }
    
    if (_checkOutTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ ra')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (isEditMode) {
        // Update existing work time
        await _updateUseCase.execute(
          id: widget.workTimeId!,
          name: _nameController.text,
          validCheckInTime: _formatTimeOfDay(_checkInTime!),
          validCheckOutTime: _formatTimeOfDay(_checkOutTime!),
          isActive: _isActive,
        );
      } else {
        // Create new work time
        await _createUseCase.execute(
          name: _nameController.text,
          validCheckInTime: _formatTimeOfDay(_checkInTime!),
          validCheckOutTime: _formatTimeOfDay(_checkOutTime!),
          isActive: _isActive,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode 
                ? 'Cập nhật ca làm việc thành công' 
                : 'Tạo ca làm việc thành công'),
          ),
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
        title: Text(isEditMode ? 'Chỉnh sửa ca làm việc' : 'Tạo ca làm việc mới'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveWorkTime,
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
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên ca làm việc';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Tên ca làm việc *',
                hintText: 'Ví dụ: Ca sáng, Ca chiều, Ca hành chính',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Giờ làm việc',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectCheckInTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Giờ vào *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.login, color: Colors.blue),
                      ),
                      child: Text(
                        _displayTime(_checkInTime),
                        style: TextStyle(
                          fontSize: 16,
                          color: _checkInTime == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectCheckOutTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Giờ ra *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.logout, color: Colors.orange),
                      ),
                      child: Text(
                        _displayTime(_checkOutTime),
                        style: TextStyle(
                          fontSize: 16,
                          color: _checkOutTime == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Trạng thái'),
              subtitle: Text(_isActive ? 'Đang hoạt động' : 'Không hoạt động'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeThumbColor: Colors.green,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ca làm việc xác định khung giờ hợp lệ để chấm công vào/ra.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveWorkTime,
                child: Text(isEditMode ? 'Cập nhật ca làm việc' : 'Tạo ca làm việc'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

