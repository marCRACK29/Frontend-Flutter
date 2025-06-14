
import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/envio_model.dart';

class DeliveryService {
  final Dio _dio = Dio();

  Future<List<EnvioModel>> obtenerEnviosPorConductor(String conductorId) async {
  try {
    final response = await _dio.get(
      ApiEndpoints.enviosConductor(conductorId),
      queryParameters: {
        'conductor_id': conductorId,
      },
      options: Options(
        headers: {
          'Ngrok-Skip-Browser-Warning': 'true',
        },
      ),
    );

    final data = response.data;

    if (data is List) {
      return data.map((json) => EnvioModel.fromJson(json)).toList();
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


  Future<void> actualizarEstadoEnvio(int envioId, String nuevoEstado) async {
    final response = await _dio.put(
      ApiEndpoints.actualizarEstadoEnvio(envioId),
      data: {
        'nuevo_estado': nuevoEstado,
      },
      options: Options(
        headers: {
          'Ngrok-Skip-Browser-Warning': 'true',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}