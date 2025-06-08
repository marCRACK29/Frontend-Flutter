import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';

class RoutingService {
  static Future<RouteResponse> getRoute(LatLng start, LatLng end) async {
    try {
      final url =
          'http://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok') {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;

          // Convertir coordenadas GeoJSON a LatLng
          final coordinates =
              geometry.map((coord) {
                return LatLng(coord[1].toDouble(), coord[0].toDouble());
              }).toList();

          return RouteResponse(
            coordinates: coordinates,
            distance: route['distance'].toDouble(),
            duration: route['duration'].toDouble(),
          );
        }
      }
      throw Exception('No se pudo obtener la ruta');
    } catch (e) {
      print('Error obteniendo ruta: $e');
      rethrow;
    }
  }
}
