import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class GeocodingService {
  static Future<Map<String, double>> getCoordinatesFromAddress(
    String address,
  ) async {
    if (address.isEmpty) {
      debugPrint('⚠️ Dirección vacía');
      throw Exception('La dirección está vacía');
    }

    debugPrint('🔍 Geocodificando dirección: $address');

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1',
        ),
        headers: {'User-Agent': 'TuApp/1.0'},
      );

      debugPrint('📡 Respuesta de Nominatim: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final result = {
            'latitude': double.parse(data[0]['lat']),
            'longitude': double.parse(data[0]['lon']),
          };
          debugPrint('✅ Coordenadas obtenidas:');
          debugPrint('   Latitud: ${result['latitude']}');
          debugPrint('   Longitud: ${result['longitude']}');
          return result;
        } else {
          debugPrint('⚠️ No se encontraron resultados para la dirección');
          throw Exception(
            'No se encontraron coordenadas para la dirección: $address',
          );
        }
      } else {
        debugPrint('❌ Error en la respuesta: ${response.statusCode}');
        throw Exception(
          'Error al geocodificar la dirección: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error en geocodificación: $e');
      throw Exception('Error al geocodificar la dirección: $e');
    }
  }
}
