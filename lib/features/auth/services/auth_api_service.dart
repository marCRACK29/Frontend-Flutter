// lib/features/auth/data/services/auth_api_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApiService {
  final String baseUrl = dotenv.env['API_URL']!;
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register/cliente';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/profile';

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode(request.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
          responseData['error'] ?? 'Error en el login: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> registerCliente(
    RegisterClienteRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          },
        body: json.encode(request.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Error en el registro');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> logout() async {
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse('$baseUrl$logoutEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
    } catch (e) {
      // El logout puede fallar pero aún así queremos limpiar el token local
      print('Error en logout: $e');
    }
  }

  Future<ClienteModel> getProfile() async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ClienteModel.fromJson(responseData);
      } else {
        throw Exception(responseData['error'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<ClienteModel> updateProfile({String? name}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;

      final response = await http.put(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ClienteModel.fromJson(responseData);
      } else {
        throw Exception(responseData['error'] ?? 'Error al actualizar perfil');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
