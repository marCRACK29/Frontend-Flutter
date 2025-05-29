import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../models/place_model.dart';
import '../../models/location_model.dart';

class OSMService {
  static OSMService? _instance;
  late Dio _dio;

  OSMService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'LICHAF-Maps-App/1.0 (Flutter)',
      },
    ));
  }

  static OSMService get instance {
    _instance ??= OSMService._internal();
    return _instance!;
  }

  /// Buscar lugares por texto
  Future<List<PlaceModel>> searchPlaces({
    required String query,
    int limit = 10,
    String? countryCode = 'cl', // Chile por defecto
  }) async {
    try {
      final url = ApiEndpoints.osmSearchUrl(
        query: query,
        limit: limit,
      );

      final response = await _dio.get(url, queryParameters: {
        if (countryCode != null) 'countrycodes': countryCode,
        'accept-language': 'es,en',
        'extratags': '1',
        'namedetails': '1',
      });

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> results = response.data;
        return results.map((json) => PlaceModel.fromOSMJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw OSMException('Error al buscar lugares: $e');
    }
  }

  /// Geocodificación inversa (coordenadas -> dirección)
  Future<PlaceModel?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = ApiEndpoints.osmReverseUrl(
        lat: latitude,
        lon: longitude,
      );

      final response = await _dio.get(url, queryParameters: {
        'accept-language': 'es,en',
        'extratags': '1',
        'namedetails': '1',
      });

      if (response.statusCode == 200 && response.data != null) {
        return PlaceModel.fromOSMJson(response.data);
      }

      return null;
    } catch (e) {
      throw OSMException('Error en geocodificación inversa: $e');
    }
  }

  /// Buscar lugares cerca de una ubicación
  Future<List<PlaceModel>> searchNearby({
    required double latitude,
    required double longitude,
    required String category, // amenity, shop, tourism, etc.
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
    try {
      // Overpass API query para buscar lugares cercanos
      final query = _buildOverpassQuery(
        latitude: latitude,
        longitude: longitude,
        category: category,
        radiusKm: radiusKm,
        limit: limit,
      );

      final response = await _dio.post(
        'https://overpass-api.de/api/interpreter',
        data: query,
        options: Options(
          headers: {'Content-Type': 'text/plain'},
        ),
      );

      if (response.statusCode == 200) {
        return _parseOverpassResponse(response.data);
      }

      return [];
    } catch (e) {
      // Fallback: usar búsqueda simple con categoría
      return await searchPlaces(
        query: '$category cerca de $latitude,$longitude',
        limit: limit,
      );
    }
  }

  /// Obtener