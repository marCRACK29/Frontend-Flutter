import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get baseUrl => dotenv.env['API_URL']!;

  static Future<Map<String, dynamic>> loginCliente(
    String email,
    String password,
  ) async {
    try {
      final body = {
        'correo': email.trim(),
        'contraseña': password,
      };

      print('Enviando petición de login: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(body),
      );

      print('Status code: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = data['user'];
        if (user != null) {
          await _saveUserInfo(user);
          return {
            'success': true,
            'message': data['message'] ?? 'Login exitoso',
            'user': user,
          };
        } else {
          return {
            'success': false,
            'message': 'Datos de usuario no recibidos',
          };
        }
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Error de login',
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user['id']);
    await prefs.setString('user_nombre', user['nombre']);
    await prefs.setString('user_correo', user['correo']);
    await prefs.setString('user_tipo', user['tipo']);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('user_id'),
      'nombre': prefs.getString('user_nombre'),
      'correo': prefs.getString('user_correo'),
      'tipo': prefs.getString('user_tipo'),
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_nombre');
    await prefs.remove('user_correo');
    await prefs.remove('user_tipo');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }

  static Future<Map<String, dynamic>> registrarCliente({
    required String rut,
    required String nombre,
    required String correo,
    required String contrasena,
    required int numeroDomicilio,
    required String calle,
    required String ciudad,
    required String region,
    required int codigoPostal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/cliente'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'RUT': rut,
          'nombre': nombre,
          'correo': correo,
          'contraseña': contrasena,
          'numero_domicilio': numeroDomicilio,
          'calle': calle,
          'ciudad': ciudad,
          'region': region,
          'codigo_postal': codigoPostal,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Cliente registrado exitosamente'};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Error de registro',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
