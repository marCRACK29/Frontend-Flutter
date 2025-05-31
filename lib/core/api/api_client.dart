import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'api_interceptors.dart';

/// Cliente HTTP singleton para manejar todas las peticiones a la API
/// Utiliza el patrón Singleton para asegurar una única instancia del cliente
///
/// La conexión con el backend se realiza de la siguiente manera:
/// 1. Se configura la URL base desde ApiEndpoints.baseUrl (que viene del .env)
/// 2. Se establecen los headers necesarios para la comunicación
/// 3. Se configuran los interceptores para logging y autenticación
/// 4. Se realizan las peticiones HTTP a través de Dio
class ApiClient {
  static ApiClient? _instance;

  /// Dio proporciona mejores funcionalidades para peticiones HTTP
  late Dio _dio;

  /// Constructor privado para implementar el patrón Singleton
  /// Aquí se configura la conexión inicial con el backend
  ApiClient._internal() {
    // Configuración inicial del cliente HTTP
    _dio = Dio(
      BaseOptions(
        // La URL base se obtiene del archivo .env a través de ApiEndpoints
        // Ejemplo: http://localhost:5000
        baseUrl: ApiEndpoints.baseUrl,

        // Tiempo máximo de espera para establecer la conexión
        connectTimeout: const Duration(seconds: 30),

        // Tiempo máximo de espera para recibir la respuesta
        receiveTimeout: const Duration(seconds: 30),

        // Headers que se envían en cada petición
        headers: {
          'Content-Type': 'application/json',

          /// Indica al servidor que los datos que se envian estan en formato json
          'Accept': 'application/json',

          /// Indica al servidor que la respuesta debe estar en formato json
          'ngrok-skip-browser-warning': 'true',

          /// Evitar que ngrok muestre su página de advertencia
        },
      ),
    );

    // Agregar interceptores para logging y autenticación
    // LoggingInterceptor: Registra todas las peticiones y respuestas
    // AuthInterceptor: Agrega tokens de autenticación si es necesario
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(AuthInterceptor());
  }

  /// Obtiene la instancia única del cliente
  /// Si no existe, la crea
  /// Esto asegura que todas las peticiones usen la misma configuración
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// Getter para acceder a la instancia de Dio
  /// Útil para acceder directamente a Dio si se necesitan funcionalidades específicas
  Dio get dio => _dio;

  /// Realiza una petición GET al backend
  /// [path] - Ruta del endpoint (se concatena con la URL base)
  /// [queryParameters] - Parámetros opcionales de la consulta (se agregan a la URL)
  ///
  /// Ejemplo: get('/api/test') -> http://localhost:5000/api/test
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición POST al backend
  /// [path] - Ruta del endpoint
  /// [data] - Datos a enviar en el cuerpo de la petición (se convierten a JSON)
  ///
  /// Ejemplo: post('/api/users', data: {'name': 'John'})
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición PUT al backend
  /// [path] - Ruta del endpoint
  /// [data] - Datos a enviar en el cuerpo de la petición
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición DELETE al backend
  /// [path] - Ruta del endpoint
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Maneja los errores de las peticiones HTTP
  /// [error] - Error capturado durante la petición
  /// Retorna una excepción con un mensaje descriptivo
  ///
  /// Tipos de errores manejados:
  /// - Timeout: Cuando la petición tarda demasiado
  /// - Bad Response: Cuando el servidor responde con un error
  /// - Connection Error: Cuando no se puede conectar al servidor
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Timeout: Revisa tu conexión a internet');
        case DioExceptionType.badResponse:
          return Exception('Error del servidor: ${error.response?.statusCode}');
        case DioExceptionType.connectionError:
          return Exception('Error de conexión');
        default:
          return Exception('Error desconocido: ${error.message}');
      }
    }
    return Exception('Error inesperado');
  }
}
