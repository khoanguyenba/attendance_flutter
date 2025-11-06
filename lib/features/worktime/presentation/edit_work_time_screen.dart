// Màn: Tạo/Sửa ca làm việc
// File này cho phép tạo mới hoặc chỉnh sửa ca làm việc (work time)
// - Mode tạo: workTimeId == null
// - Mode sửa: workTimeId != null (load dữ liệu từ API)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../domain/usecases/create_work_time_usecase.dart';
import '../domain/usecases/update_work_time_usecase.dart';
import '../domain/usecases/get_work_time_by_id_usecase.dart';

// Widget chính cho màn tạo/sửa ca làm việc
// - workTimeId == null => tạo mới
// - workTimeId != null => chỉnh sửa
class EditWorkTimeScreen extends StatefulWidget {
  final String? workTimeId; // null = chế độ tạo, !null = chế độ sửa

  const EditWorkTimeScreen({super.key, this.workTimeId});

  @override
  State<EditWorkTimeScreen> createState() => _EditWorkTimeScreenState();
}

class _EditWorkTimeScreenState extends State<EditWorkTimeScreen> {
  // UseCase để tạo ca làm việc mới
  late final CreateWorkTimeUseCase _createUseCase;
  // UseCase để cập nhật ca làm việc
  late final UpdateWorkTimeUseCase _updateUseCase;
  // UseCase để lấy thông tin ca làm việc theo ID (dùng khi sửa)
  late final GetWorkTimeByIdUseCase _getByIdUseCase;

  // Key để quản lý validation form
  final _formKey = GlobalKey<FormState>();
  // Controller cho tên ca làm việc
  final _nameController = TextEditingController();

  // Thời gian check-in và check-out (giờ phút)
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  // Trạng thái ca làm việc có đang hoạt động hay không
  bool _isActive = true;

  // Trạng thái loading và error
  bool isLoading = false;
  String? error;

  // Kiểm tra xem đang ở chế độ sửa hay tạo
  bool get isEditMode => widget.workTimeId != null;

  @override
  void initState() {
    super.initState();
    // Lấy các UseCase từ DI container
    _createUseCase = resolve<CreateWorkTimeUseCase>();
    _updateUseCase = resolve<UpdateWorkTimeUseCase>();
    _getByIdUseCase = resolve<GetWorkTimeByIdUseCase>();

    // Nếu chế độ sửa, tải dữ liệu ca làm việc hiện tại
    if (isEditMode) {
      _loadWorkTime();
    }
  }

  // Tải thông tin ca làm việc khi ở chế độ sửa
  Future<void> _loadWorkTime() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final workTime = await _getByIdUseCase.execute(widget.workTimeId!);
      if (workTime != null) {
        // Điền dữ liệu vào form
        _nameController.text = workTime.name;
        setState(() {
          _isActive = workTime.isActive;
          // Parse chuỗi thời gian thành TimeOfDay
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

  // Chuyển đổi chuỗi thời gian (HH:mm:ss) sang TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    // Format: HH:mm:ss
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Chuyển đổi TimeOfDay thành chuỗi (HH:mm:ss) để gửi lên API
  String _formatTimeOfDay(TimeOfDay time) {
    // Format to HH:mm:ss
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  // Hiển thị thời gian trong UI (HH:mm)
  String _displayTime(TimeOfDay? time) {
    if (time == null) return 'Chưa chọn';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Hiển thị dialog để chọn giờ vào
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

  // Hiển thị dialog để chọn giờ ra
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

  // Lưu ca làm việc (tạo mới hoặc cập nhật tùy theo mode)
  Future<void> _saveWorkTime() async {
    // Validate form trước
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra đã chọn giờ vào chưa
    if (_checkInTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn giờ vào')));
      return;
    }

    // Kiểm tra đã chọn giờ ra chưa
    if (_checkOutTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn giờ ra')));
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (isEditMode) {
        // Cập nhật ca làm việc đã tồn tại
        await _updateUseCase.execute(
          id: widget.workTimeId!,
          name: _nameController.text,
          validCheckInTime: _formatTimeOfDay(_checkInTime!),
          validCheckOutTime: _formatTimeOfDay(_checkOutTime!),
          isActive: _isActive,
        );
      } else {
        // Tạo ca làm việc mới
        await _createUseCase.execute(
          name: _nameController.text,
          validCheckInTime: _formatTimeOfDay(_checkInTime!),
          validCheckOutTime: _formatTimeOfDay(_checkOutTime!),
          isActive: _isActive,
        );
      }

      if (mounted) {
        // Hiện thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Cập nhật ca làm việc thành công'
                  : 'Tạo ca làm việc thành công',
            ),
          ),
        );
        // Quay lại màn trước và trả về true (để màn list reload)
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
        title: Text(
          isEditMode ? 'Chỉnh sửa ca làm việc' : 'Tạo ca làm việc mới',
        ),
        actions: [
          // Nút Lưu ở AppBar
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
    // Nếu đang loading (trong edit mode) thì hiện vòng tròn loading
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
            // Trường nhập tên ca làm việc
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Chọn giờ vào
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
                          color: _checkInTime == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Chọn giờ ra
                Expanded(
                  child: InkWell(
                    onTap: _selectCheckOutTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Giờ ra *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(
                          Icons.logout,
                          color: Colors.orange,
                        ),
                      ),
                      child: Text(
                        _displayTime(_checkOutTime),
                        style: TextStyle(
                          fontSize: 16,
                          color: _checkOutTime == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Switch để bật/tắt trạng thái ca làm việc
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
            // Thông tin hướng dẫn
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
            // Nút lưu (ở dưới cùng của form)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveWorkTime,
                child: Text(
                  isEditMode ? 'Cập nhật ca làm việc' : 'Tạo ca làm việc',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
