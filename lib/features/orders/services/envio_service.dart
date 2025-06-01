import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/envio_model.dart';

class EnvioService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, dynamic>> crearEnvio(Envio envio) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/envios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(envio.toJson()),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear el envío: ${response.body}');
    }
  }

  Future<List<dynamic>> obtenerEnviosPorUsuario(String usuarioId) async {
    final uri = Uri.parse(baseUrl).replace(
      path: '/api/envios/mis',
      queryParameters: {'usuario_id': usuarioId.trim()},
    );
    print('Consultando URL: $uri');
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('Solicitud incorrecta: ${response.body}');
    } else if (response.statusCode == 500) {
      throw Exception('Error del servidor: ${response.body}');
    } else {
      throw Exception('Error inesperado: ${response.body}');
    }
  }


}
