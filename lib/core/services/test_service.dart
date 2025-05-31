import '../api/api_client.dart';

/// Servicio para probar la conexión con el backend
/// Este servicio realiza una petición GET al endpoint /api/test
/// para verificar que el backend está funcionando correctamente
class TestService {
  /// Prueba la conexión con el backend
  ///
  /// El flujo de conexión es el siguiente:
  /// 1. Utiliza ApiClient (singleton) para hacer la petición
  /// 2. ApiClient usa Dio para realizar la petición HTTP
  /// 3. La petición se envía a la URL base + '/api/test'
  /// 4. Se espera una respuesta con status 200 y datos en formato JSON
  ///
  /// @return Future<String> - Mensaje indicando el resultado de la conexión
  Future<String> testConnection() async {
    try {
      // Realiza la petición GET al endpoint /api/test
      // ApiClient.instance.get() utiliza la URL base configurada en .env
      final response = await ApiClient.instance.get('/api/test');

      // Verifica si la respuesta fue exitosa (código 200)
      if (response.statusCode == 200) {
        // Verifica si la respuesta es un JSON válido
        if (response.data is Map<String, dynamic>) {
          // Extrae el mensaje del JSON o usa un mensaje por defecto
          return response.data['message']?.toString() ??
              'Respuesta exitosa sin mensaje';
        } else {
          // Si la respuesta no es JSON, devuelve la respuesta como string
          return 'Respuesta exitosa: ${response.data.toString()}';
        }
      } else {
        // Si el código de estado no es 200, devuelve el error
        return 'Error: Código de estado ${response.statusCode}';
      }
    } catch (e) {
      // Captura cualquier error durante la petición
      return 'Error de conexión: ${e.toString()}';
    }
  }
}
