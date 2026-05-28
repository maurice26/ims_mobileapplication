import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import 'auth_service.dart';

class ApiService {
  static Dio? _dio; // rename to private

  static Dio get instance {
    if (_dio != null) return _dio!; // ← return early, don't re-add interceptors

    final baseUrl = Config.getApiUrl();

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    if (kDebugMode) {
      print('[ApiService] baseUrl=$baseUrl');
    }

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token injection for auth endpoints
          final isAuthEndpoint = options.path.contains('/auth/');
          if (!isAuthEndpoint) {
            final token = await AuthService().getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
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
              try {
                final clone = await _dio!.fetch(error.requestOptions);
                handler.resolve(clone);
              } catch (e) {
                handler.next(error);
              }
              return;
            }

            final path = error.requestOptions.path;
            final method = error.requestOptions.method;
            final base = _dio?.options.baseUrl;
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
            await AuthService().logout();
          }
          handler.next(error);
        },
      ),
    );

    return _dio!;
  }

  // Add a reset method for logout
  static void reset() {
    _dio = null;
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
      throw Exception(
        'Login failed (check API_BASE_URL / backend on port 7188). Error: $e',
      );
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
      throw Exception(
        'Register failed (check API_BASE_URL / backend on port 7188). Error: $e',
      );
    }
  }
}
