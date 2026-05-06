import 'package:dio/dio.dart';

import '../config.dart';
import 'auth_service.dart';

class ApiService {
  static Dio? dio;

  static Dio get instance {
    dio ??= Dio(
      BaseOptions(
        baseUrl: Config.getApiUrl(), // ✅ FIXED: Use dynamic URL
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Interceptor for token
    dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthService().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            AuthService().logout();
          }
          handler.next(error);
        },
      ),
    );

    return dio!;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await instance.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      return {'token': token, 'user': data['user']};
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await instance.post(
        '/api/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }
}
