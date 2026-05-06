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
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
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
        onError: (error, handler) async {
          // Simple retry for transient timeout / network issues.
          final isTimeout =
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.unknown;

          if (isTimeout) {
            final retries =
                (error.requestOptions.extra['retries'] as int?) ?? 0;
            if (retries < 2) {
              error.requestOptions.extra['retries'] = retries + 1;
              final backoffMs = 500 * (1 << retries);
              await Future.delayed(Duration(milliseconds: backoffMs));
              final clone = await dio!.fetch(error.requestOptions);
              handler.resolve(clone);
              return;
            }

            final path = error.requestOptions.path;
            final method = error.requestOptions.method;
            final base = dio?.options.baseUrl;
            final url = '${base ?? ''}$path';
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: error.type,
                error:
                    'Connection timeout after retries. url=$url method=$method',
              ),
            );
            return;
          }

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
