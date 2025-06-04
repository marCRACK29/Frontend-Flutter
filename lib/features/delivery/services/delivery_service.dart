import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/envio_model.dart';

class DeliveryService {
  final Dio _dio = Dio();

  Future<List<EnvioModel>> obtenerEnviosPorConductor(String conductorId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.enviosConductor,
        queryParameters: {'conductor_id': conductorId},
        options: Options(headers: {'Ngrok-Skip-Browser-Warning': 'true'}),
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((json) => EnvioModel.fromBackendResponse(json))
            .toList();
      }

      if (data is Map && data.containsKey('mensaje')) {
        // Por ejemplo: { "mensaje": "No tienes envíos asignados" }
        return [];
      }

      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // NUEVO: Método para obtener un envío específico por ID
  Future<EnvioModel> obtenerEnvioPorId(int envioId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/api/envios/$envioId',
        options: Options(headers: {'Ngrok-Skip-Browser-Warning': 'true'}),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return EnvioModel.fromBackendResponse(data);
      }

      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Envío no encontrado');
        }
        throw Exception('Error del servidor: ${e.response?.statusCode}');
      }
      throw Exception('Error de red: $e');
    }
  }

  // OPCIONAL: Método para obtener solo el estado actual de un envío
  Future<String> obtenerEstadoEnvio(int envioId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/api/envios/$envioId/estado',
        options: Options(headers: {'Ngrok-Skip-Browser-Warning': 'true'}),
      );

      final data = response.data;

      if (data is Map && data.containsKey('estado')) {
        return data['estado'];
      }

      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Envío no encontrado');
        }
        throw Exception('Error del servidor: ${e.response?.statusCode}');
      }
      throw Exception('Error de red: $e');
    }
  }

  Future<void> actualizarEstadoEnvio(int envioId, String nuevoEstado) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}/envios/estado',
        data: {'envio_id': envioId, 'nuevo_estado': nuevoEstado},
        options: Options(headers: {'Ngrok-Skip-Browser-Warning': 'true'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar estado');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Error del servidor: ${e.response?.statusCode}');
      }
      throw Exception('Error al comunicarse con el servidor: $e');
    }
  }
}
