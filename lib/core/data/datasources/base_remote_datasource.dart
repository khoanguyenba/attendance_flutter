import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final String baseUrl = 'http://localhost:5190';

  BaseRemoteDataSource(this.dio, this.secureStorage) {
    dio.options.baseUrl = baseUrl;
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
}
