import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';

class ClienteService {
  final String baseUrl = 'http://localhost:5000/api'; // Ajusta según tu configuración

  Future<Cliente> obtenerInfoCliente(String rut) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cliente/info?rut_cliente=$rut'),
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
        headers: {'Content-Type': 'application/json'},
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