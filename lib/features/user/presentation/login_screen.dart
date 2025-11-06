// Màn: Đăng nhập
// File này hiển thị form đăng nhập, cho phép người dùng nhập username/password
// và cấu hình URL API server (settings button ở góc phải trên)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/di/injection.dart';
import '../../../core/presentation/authenticated_layout.dart';
import '../domain/usecases/login_usecase.dart';

// Widget chính cho màn đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // UseCase để thực hiện đăng nhập
  late final LoginUseCase _loginUseCase;
  // Secure storage để lưu base URL
  late final FlutterSecureStorage _secureStorage;

  // Form key cho validation
  final _formKey = GlobalKey<FormState>();
  // Controller cho input username và password
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Trạng thái hiển thị/ẩn password
  bool _isPasswordVisible = false;
  // Trạng thái loading khi đang đăng nhập
  bool isLoading = false;
  // Thông báo lỗi (nếu có)
  String? error;
  // Base URL hiện tại của API
  String _currentBaseUrl = 'http://localhost:5190';

  @override
  void initState() {
    super.initState();
    // Lấy các dependency từ DI
    _loginUseCase = resolve<LoginUseCase>();
    _secureStorage = resolve<FlutterSecureStorage>();
    // Tải base URL đã lưu (nếu có)
    _loadBaseUrl();
  }

  // Tải base URL đã lưu từ secure storage
  Future<void> _loadBaseUrl() async {
    final savedUrl = await _secureStorage.read(key: 'base_url');
    if (savedUrl != null && mounted) {
      setState(() {
        _currentBaseUrl = savedUrl;
      });
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Thực hiện đăng nhập
  Future<void> _login() async {
    // Validate form trước
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Gọi usecase để đăng nhập
      await _loginUseCase.call(
        _userNameController.text,
        _passwordController.text,
      );

      if (mounted) {
        // Đăng nhập thành công, chuyển sang màn attendance
        context.go('/attendance');
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

  // Hiển thị dialog cấu hình API URL
  Future<void> _showConfigDialog() async {
    final urlController = TextEditingController(text: _currentBaseUrl);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cấu hình API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập địa chỉ API server',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost:5190',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ví dụ: http://192.168.1.100:5190',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = urlController.text.trim();
              if (newUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập địa chỉ API')),
                );
                return;
              }

              // Validate URL format (phải bắt đầu bằng http:// hoặc https://)
              if (!newUrl.startsWith('http://') &&
                  !newUrl.startsWith('https://')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'URL phải bắt đầu bằng http:// hoặc https://',
                    ),
                  ),
                );
                return;
              }

              // Lưu URL mới vào secure storage
              await _secureStorage.write(key: 'base_url', value: newUrl);
              setState(() {
                _currentBaseUrl = newUrl;
              });

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu cấu hình API')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Nút Settings ở góc phải trên để cấu hình API
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showConfigDialog,
                tooltip: 'Cấu hình API',
              ),
            ),
            // Nội dung chính: form đăng nhập
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo ứng dụng
                      Icon(
                        Icons.business,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      // Tiêu đề hệ thống
                      Text(
                        'Hệ thống chấm công',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập để tiếp tục',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 48),

                      // Hiển thị thông báo lỗi nếu đăng nhập thất bại
                      if (error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                              ),
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

                      // Trường nhập tên đăng nhập
                      TextFormField(
                        controller: _userNameController,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên đăng nhập';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trường nhập mật khẩu (có nút show/hide password)
                      TextFormField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nút đăng nhập (hiện loading indicator khi đang xử lý)
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nút quên mật khẩu (optional, có thể bỏ comment nếu cần)
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // TODO: Navigate to forgot password screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tính năng đang phát triển'),
                                  ),
                                );
                              },
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
