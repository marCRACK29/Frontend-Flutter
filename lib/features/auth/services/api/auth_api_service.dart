import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../models/user_model.dart';

class AuthApiService {
  final ApiClient _client = ApiClient.instance;

  // Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error de conexión durante login: $e');
    }
  }

  // Register
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error de conexión durante registro: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (e) {
      // Logout can continue even if server call fails
      throw Exception('Error durante logout: $e');
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      } else {
        throw Exception('Failed to load profile: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al cargar perfil: $e');
    }
  }

  // Update profile
  Future<User> updateProfile({String? name, String? phone}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;

      final response = await _client.put(
        ApiEndpoints.profile,
        data: data,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      } else {
        throw Exception('Failed to update profile: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Token refresh failed: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al refrescar token: $e');
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _client.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send reset email: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset password: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al restablecer contraseña: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }
}