import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static SecureStorage? _instance;
  late FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  SecureStorage._internal() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    _initPrefs();
  }

  static SecureStorage get instance {
    _instance ??= SecureStorage._internal();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: _userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _userEmailKey);
  }

  // Session management
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveLoginSession({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
  }) async {
    await Future.wait([
      saveToken(token),
      saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveUserEmail(email),
    ]);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }

  // User preferences (non-secure)
  Future<void> saveUserPreference(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getUserPreference(String key) {
    return _prefs?.getString(key);
  }

  Future<void> saveBoolPreference(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBoolPreference(String key) {
    return _prefs?.getBool(key);
  }

  // App settings
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _firstLaunchKey = 'first_launch';

  Future<void> saveThemeMode(String theme) async {
    await saveUserPreference(_themeKey, theme);
  }

  String getThemeMode() {
    return getUserPreference(_themeKey) ?? 'system';
  }

  Future<void> saveLanguage(String language) async {
    await saveUserPreference(_languageKey, language);
  }

  String getLanguage() {
    return getUserPreference(_languageKey) ?? 'es';
  }

  Future<void> setFirstLaunchComplete() async {
    await saveBoolPreference(_firstLaunchKey, true);
  }

  bool isFirstLaunch() {
    return getBoolPreference(_firstLaunchKey) ?? true;
  }
}
