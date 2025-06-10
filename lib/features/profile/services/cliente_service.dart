import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/cliente_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ClienteService {
  static String get baseUrl => dotenv.env['API_URL']!; // Ajusta según tu configuración

  Future<Cliente> obtenerInfoCliente(String rut) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cliente/info?rut_cliente=$rut'),
        headers: {'Content-Type': 'application/json','ngrok-skip-browser-warning': 'true'},
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
        Uri.parse('$baseUrl/api/cliente/correo'),
        headers: {'Content-Type': 'application/json','ngrok-skip-browser-warning': 'true'},
        body: json.encode({
          'rut_cliente': rut,
          'nuevo_correo': nuevoCorreo,
        }),
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
