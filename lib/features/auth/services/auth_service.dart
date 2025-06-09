import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../../core/storage/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get baseUrl => dotenv.env['API_URL']!;
  final SecureStorage _storage = SecureStorage.instance;

  static Future<Map<String, dynamic>> loginCliente(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Guardar token
        await _saveToken(data['token']);
        return {'success': true, 'message': 'Login exitoso'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Error de login'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  // Registro de cliente
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

  // Guardar token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Obtener token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Verificar si está logueado
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
