import 'package:flutter/material.dart';
import '../domain/entities/attendance_wifi.dart';
import '../data/datasources/attendance_wifi_remote_datasource.dart';

class AttendanceWiFiListScreen extends StatefulWidget {
  const AttendanceWiFiListScreen({super.key});

  @override
  State<AttendanceWiFiListScreen> createState() => _AttendanceWiFiListScreenState();
}

class _AttendanceWiFiListScreenState extends State<AttendanceWiFiListScreen> {
  final AttendanceWiFiRemoteDataSource _dataSource = AttendanceWiFiRemoteDataSourceImpl();
  List<AttendanceWiFi> attendanceWiFis = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAttendanceWiFis();
  }

  Future<void> _loadAttendanceWiFis() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _dataSource.getAttendanceWiFis();
      setState(() {
        attendanceWiFis = result.map((m) => AttendanceWiFi(
          id: m.id,
          location: m.location,
          ssid: m.ssid,
          bssid: m.bssid,
          description: m.description,
          createdAt: m.createdAt,
        )).toList();
      });
    } catch (e) {
      // Fallback to mock data so UI stays usable when API is down
      setState(() {
        attendanceWiFis = [
          AttendanceWiFi(
            id: 'local-1',
            location: 'Văn phòng chính',
            ssid: 'Office-WiFi',
            bssid: '00:11:22:33:44:55',
            description: 'WiFi chính tại văn phòng',
            createdAt: DateTime.now(),
          ),
        ];
        error = 'Không thể tải danh sách từ API: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAttendanceWiFi(AttendanceWiFi attendanceWiFi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa WiFi "${attendanceWiFi.location}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dataSource.deleteAttendanceWiFi(attendanceWiFi.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa WiFi thành công')),
          );
          _loadAttendanceWiFis();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý WiFi chấm công'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
                    // Create screen is not available in this branch of the codebase.
                    // Show a message instead of navigating to a missing file.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng tạo WiFi chưa khả dụng')),
                    );
            },
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

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $error'),
            ElevatedButton(
              onPressed: _loadAttendanceWiFis,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (attendanceWiFis.isEmpty) {
      return const Center(
        child: Text('Không có WiFi nào được cấu hình'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttendanceWiFis,
      child: ListView.builder(
        itemCount: attendanceWiFis.length,
        itemBuilder: (context, index) {
          final attendanceWiFi = attendanceWiFis[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.wifi),
              title: Text(attendanceWiFi.location),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SSID: ${attendanceWiFi.ssid}'),
                  Text('BSSID: ${attendanceWiFi.bssid}'),
                  if (attendanceWiFi.description != null)
                    Text('Mô tả: ${attendanceWiFi.description}'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    // Edit screen is not available here; show message instead.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng chỉnh sửa chưa khả dụng')),
                    );
                  } else if (value == 'delete') {
                    _deleteAttendanceWiFi(attendanceWiFi);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
