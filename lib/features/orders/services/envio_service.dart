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
    final response = await http.get(
      Uri.parse('$baseUrl/api/envios/mis?usuario_id=$usuarioId'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Tipo de respuesta: ${data.runtimeType}");

      if (data is List) {
        return data;
      } else {
        throw Exception('Respuesta inesperada: se esperaba una lista de envíos.');
      }
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}