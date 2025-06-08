import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';

class RoutingService {
  static const String _osrmUrl = 'https://router.project-osrm.org';

  static Future<RouteResponse?> getRoute(LatLng start, LatLng end) async {
    try {
      final url = '$_osrmUrl/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RouteResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }
}

