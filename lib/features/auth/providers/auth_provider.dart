import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/storage/secure_storage.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final SecureStorage _storage = SecureStorage.instance;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _storage.isLoggedIn();
      if (isLoggedIn) {
        await _loadUserFromStorage();
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error al inicializar autenticación');
      _setState(AuthState.unauthenticated);
    }
    _setLoading(false);
  }

  // Login
  Future<bool> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _authService.login(request);

      // Save to secure storage
      await _storage.saveLoginSession(
        token: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.rut,
        email: response.user.correo,
      );

      _user = response.user;
      _setState(AuthState.authenticated);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Credenciales inválidas. Verifica tu email y contraseña.');
      _setState(AuthState.error);
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register(
    String email,
    String password,
    String rut,
    String nombre,
    int numero_domicilio,
    String calle,
    String ciudad,
    String region,
    int codigo_postal,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final request = RegisterRequest(
        rut: rut,
        nombre: nombre,
        correo: email,
        contrasena: password,
        numero_domicilio: numero_domicilio,
        calle: calle,
        ciudad: ciudad,
        region: region,
        codigo_postal: codigo_postal,
      );

      final response = await _authService.register(request);

      // Save to secure storage
      await _storage.saveLoginSession(
        token: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.rut,
        email: response.user.correo,
      );

      _user = response.user;
      _setState(AuthState.authenticated);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al crear la cuenta. El email podría estar en uso.');
      _setState(AuthState.error);
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      if (kDebugMode) print('Error during logout: $e');
    }

    await _storage.clearAll();
    _user = null;
    _setState(AuthState.unauthenticated);
    _setLoading(false);
  }

  // Load user profile
  Future<void> loadProfile() async {
    if (!isAuthenticated) return;

    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar perfil');
    }
  }

  // Update profile
  Future<bool> updateProfile({String? name, String? phone}) async {
    if (!isAuthenticated || _user == null) return false;

    _setLoading(true);
    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
      );
      _user = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar perfil');
      _setLoading(false);
      return false;
    }
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
  }

  Future<void> _loadUserFromStorage() async {
    final userId = await _storage.getUserId();
    final email = await _storage.getUserEmail();

    if (userId != null && email != null) {
      _user = User(
        rut: userId,
        nombre: '', // Temporal
        correo: email,
        tipo: 'cliente', // Temporal
        numero_domicilio: 0, // Temporal
        calle: '', // Temporal
        ciudad: '', // Temporal
        region: '', // Temporal
        codigo_postal: 0, // Temporal
      );
      // Optionally load full profile from API
      try {
        await loadProfile();
      } catch (e) {
        // Use cached user data if API fails
        if (kDebugMode) print('Could not load profile from API: $e');
      }
    }
  }

  // Clear error
  void clearError() {
    _clearError();
  }
}
