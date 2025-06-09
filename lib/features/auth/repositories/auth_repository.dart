// lib/features/auth/data/repositories/auth_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cliente_model.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  final AuthApiService _apiService;

  AuthRepository(this._apiService);

  Future<ClienteModel> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);
      
      // Guardar token
      if (response['token'] != null) {
        await _saveToken(response['token']);
      }
      
      // Retornar usuario
      if (response['usuario'] != null) {
        return ClienteModel.fromJson(response['usuario']);
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  Future<ClienteModel> registerCliente({
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
      final request = RegisterClienteRequest(
        rut: rut,
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
        numeroDomicilio: numeroDomicilio,
        calle: calle,
        ciudad: ciudad,
        region: region,
        codigoPostal: codigoPostal,
      );
      
      final response = await _apiService.registerCliente(request);
      
      // Retornar usuario registrado
      if (response['usuario'] != null) {
        return ClienteModel.fromJson(response['usuario']);
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      // Siempre limpiar el token local, incluso si el logout falla
      await _clearToken();
    }
  }

  Future<ClienteModel> getProfile() async {
    return await _apiService.getProfile();
  }

  Future<ClienteModel> updateProfile({String? name}) async {
    return await _apiService.updateProfile(name: name);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}