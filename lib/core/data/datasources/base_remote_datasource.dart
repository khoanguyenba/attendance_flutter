import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  static const String defaultBaseUrl = 'http://localhost:5190';

  BaseRemoteDataSource(this.dio, this.secureStorage) {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    final baseUrl = await getBaseUrl();
    dio.options.baseUrl = baseUrl;
    dio.options.validateStatus = (status) => status != null && status < 500;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await clearToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  Future<String> getBaseUrl() async {
    final savedUrl = await secureStorage.read(key: 'base_url');
    return savedUrl ?? defaultBaseUrl;
  }

  Future<void> saveBaseUrl(String url) async {
    await secureStorage.write(key: 'base_url', value: url);
    dio.options.baseUrl = url;
  }
}
