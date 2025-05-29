import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 REQUEST: ${options.method} ${options.uri}');
      print('📤 Data: ${options.data}');
      print('📋 Headers: ${options.headers}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ RESPONSE: ${response.statusCode} ${response.realUri}');
      print('📥 Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ ERROR: ${err.response?.statusCode} ${err.message}');
      print('📍 URL: ${err.requestOptions.uri}');
      print('📄 Response: ${err.response?.data}');
    }
    handler.next(err);
  }
}

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage = SecureStorage.instance;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Solo agregar token a endpoints que requieren autenticación
    if (_requiresAuth(options.path)) {
      final token = await _storage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si recibimos 401, intentamos refrescar el token
    if (err.response?.statusCode == 401 &&
        _requiresAuth(err.requestOptions.path)) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Reintentar la request original
          final newToken = await _storage.getToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          final dio = Dio();
          final response = await dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );

          return handler.resolve(response);
        }
      } catch (e) {
        // Si falla el refresh, limpiar storage y redirigir a login
        await _storage.clearAll();
        // Aquí podrías emitir un evento para redirigir a login
      }
    }
    handler.next(err);
  }

  bool _requiresAuth(String path) {
    // Paths que NO requieren autenticación
    final publicPaths = ['/auth/login', '/auth/register'];
    return !publicPaths.any((publicPath) => path.contains(publicPath));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        'http://localhost:5000/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        await _storage.saveToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
