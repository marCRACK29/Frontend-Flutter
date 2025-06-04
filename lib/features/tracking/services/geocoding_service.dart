import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeocodingService {
  static Future<Map<String, double>> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1',
        ),
        headers: {'User-Agent': 'TuApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'latitude': double.parse(data[0]['lat']),
            'longitude': double.parse(data[0]['lon']),
          };
        }
      }
      throw Exception('No se pudo obtener las coordenadas');
    } catch (e) {
      throw Exception('Error al geocodificar la dirección: $e');
    }
  }
}
