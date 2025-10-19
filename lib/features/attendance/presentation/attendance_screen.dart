import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:attendance_system/core/routing/route_constraint.dart';
import '../domain/entities/attendance.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isLoading = false;
  String? error;
  String? currentWifiSSID;
  String? currentWifiBSSID;
  bool hasCheckedInToday = false;
  bool hasCheckedOutToday = false;
  String employeeId = 'mock-employee-id'; // TODO: Get from auth

  @override
  void initState() {
    super.initState();
    _getWifiInfo();
    _checkTodayAttendance();
  }

  Future<void> _getWifiInfo() async {
    try {
      // Check if running on Web platform
      if (kIsWeb) {
        setState(() {
          currentWifiSSID = 'Web Platform';
          currentWifiBSSID = 'N/A';
          // Don't set error here, just a warning message in UI
        });
        return;
      }

      final permission = await Permission.location.request();
      if (permission.isGranted) {
        final ssid = await NetworkInfo().getWifiName();
        final bssid = await NetworkInfo().getWifiBSSID();
        
        setState(() {
          currentWifiSSID = ssid?.replaceAll('"', '');
          currentWifiBSSID = bssid;
          error = null;
        });
      } else {
        setState(() {
          error = 'Cần cấp quyền truy cập vị trí để lấy thông tin WiFi';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Không thể lấy thông tin WiFi: $e';
      });
    }
  }

  Future<void> _checkTodayAttendance() async {
    try {
      // TODO: Implement actual API call
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        hasCheckedInToday = false; // Mock data
        hasCheckedOutToday = false; // Mock data
      });
    } catch (e) {
      // Ignore error for checking today's attendance
    }
  }

  Future<void> _performCheckIn() async {
    // On web, allow check-in without WiFi validation
    if (!kIsWeb && (currentWifiSSID == null || currentWifiBSSID == null)) {
      setState(() {
        error = 'Không thể lấy thông tin WiFi. Vui lòng kiểm tra kết nối mạng.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in thành công! Trạng thái: Đúng giờ'),
          ),
        );
        setState(() {
          hasCheckedInToday = true;
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

  Future<void> _performCheckOut() async {
    // On web, allow check-out without WiFi validation
    if (!kIsWeb && (currentWifiSSID == null || currentWifiBSSID == null)) {
      setState(() {
        error = 'Không thể lấy thông tin WiFi. Vui lòng kiểm tra kết nối mạng.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out thành công! Trạng thái: Đúng giờ'),
          ),
        );
        setState(() {
          hasCheckedOutToday = true;
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

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Đúng giờ';
      case 1:
        return 'Muộn';
      case 2:
        return 'Sớm';
      default:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWifiInfoCard(),
          const SizedBox(height: 24),
          _buildAttendanceCard(),
          const SizedBox(height: 24),
          _buildHistoryButton(),
          if (error != null) ...[
            const SizedBox(height: 16),
            _buildErrorCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildWifiInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin WiFi hiện tại',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('SSID', currentWifiSSID ?? 'Đang tải...'),
            _buildInfoRow('BSSID', currentWifiBSSID ?? 'Đang tải...'),
            if (kIsWeb) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trình duyệt web không hỗ trợ lấy thông tin WiFi. Vui lòng sử dụng ứng dụng mobile hoặc desktop.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _getWifiInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chấm công hôm nay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceButton(
                    title: 'Check In',
                    icon: Icons.login,
                    color: hasCheckedInToday ? Colors.grey : Colors.green,
                    onPressed: hasCheckedInToday ? null : _performCheckIn,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAttendanceButton(
                    title: 'Check Out',
                    icon: Icons.logout,
                    color: hasCheckedOutToday ? Colors.grey : Colors.orange,
                    onPressed: hasCheckedOutToday ? null : _performCheckOut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasCheckedInToday)
              const Text(
                '✓ Đã check-in hôm nay',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            if (hasCheckedOutToday)
              const Text(
                '✓ Đã check-out hôm nay',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử chấm công',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Xem lịch sử chấm công của bạn',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go(RouteConstraint.attendanceHistory),
                icon: const Icon(Icons.history),
                label: const Text('Xem lịch sử'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
