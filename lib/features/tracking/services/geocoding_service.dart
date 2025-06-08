import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';

  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = '$_nominatimUrl/search?q=$encodedAddress&format=json&limit=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'ConductorTrackingApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final result = results[0];
          return LatLng(
            double.parse(result['lat']),
            double.parse(result['lon']),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final url = '$_nominatimUrl/reverse?lat=${coordinates.latitude}&lon=${coordinates.longitude}&format=json';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'ConductorTrackingApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['display_name'];
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }
}

