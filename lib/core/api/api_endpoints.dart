import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // Base URLs
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'http://localhost:5000'; // Tu Flask backend
  static const String osmBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String osmTileUrl =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Maps endpoints
  static const String routes = '/maps/routes';
  static const String locations = '/maps/locations';
  static const String places = '/maps/places';
  static const String saveRoute = '/maps/routes/save';

  // OSM endpoints
  static const String osmSearch = '/search';
  static const String osmReverse = '/reverse';
  static const String osmDetails = '/details';

<<<<<<< Updated upstream
=======
  // Orders endpoints
  static const String createEnvio = "/api/envios";
  static const String misEnvios = "/api/envios/mis";
  static String actualizarEstado(int id) => "/api/envios/$id/estado";
  static String cancelarEnvio(int id) => "/api/envios/$id";

  static String actualizarEstadoEnvio(int envioId) => '$baseUrl/api/envios/$envioId/estado';
  static String enviosConductor(String conductorId) => '$baseUrl/api/envios/conductor?conductor_id=$conductorId';


  


>>>>>>> Stashed changes
  // Helper methods
  static String getUserRoutes(String userId) => '/maps/routes/user/$userId';
  static String getRouteById(String routeId) => '/maps/routes/$routeId';
  static String deleteRoute(String routeId) => '/maps/routes/$routeId';

  // OSM helpers
  static String osmSearchUrl({
    required String query,
    String format = 'json',
    int limit = 5,
  }) {
    return '$osmBaseUrl$osmSearch?q=$query&format=$format&limit=$limit&addressdetails=1';
  }

  static String osmReverseUrl({
    required double lat,
    required double lon,
    String format = 'json',
  }) {
    return '$osmBaseUrl$osmReverse?lat=$lat&lon=$lon&format=$format&addressdetails=1';
  }
}
