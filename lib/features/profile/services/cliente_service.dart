import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/cliente_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClienteService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:5000';
  final storage = const FlutterSecureStorage();

  Future<Cliente> obtenerInfoCliente(String rut) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),  
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        return Cliente.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener información del cliente');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Cliente> actualizarCorreo(String rut, String nuevoCorreo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cliente/correo'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode({'rut_cliente': rut, 'nuevo_correo': nuevoCorreo}),
      );

      if (response.statusCode == 200) {
        return Cliente.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar el correo');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
