import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/// Servicio que maneja las interacciones con las APIs de OpenStreetMap:
/// - Nominatim: para búsqueda de ubicaciones
/// - OSRM: para cálculo de rutas
class NominatimOsrmService {
  /// Busca una ubicación usando la API de Nominatim
  ///
  /// [query] es el texto de búsqueda (ej: "Santiago, Chile")
  /// Retorna las coordenadas (latitud, longitud) si se encuentra la ubicación
  Future<LatLng?> buscarUbicacion(String query) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1",
    );
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final data = json.decode(respuesta.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  /// Calcula la ruta entre dos puntos usando la API de OSRM
  ///
  /// [from] es el punto de origen
  /// [to] es el punto de destino
  /// Retorna una lista de puntos que forman la ruta
  Future<List<LatLng>> fetchRoute(LatLng from, LatLng to) async {
    final url = Uri.parse(
      "http://router.project-osrm.org/route/v1/driving/"
      '${from.longitude},${from.latitude};'
      '${to.longitude},${to.latitude}?overview=full&geometries=polyline',
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final data = json.decode(respuesta.body);
      final geometry = data['routes'][0]['geometry'];
      return _decodePolyline(geometry);
    }
    return [];
  }

  /// Decodifica una polilínea codificada en un formato para OpenStreetMap
  ///
  /// [encodedPolyline] es la cadena codificada que representa la ruta
  /// Retorna una lista de puntos LatLng que forman la ruta
  List<LatLng> _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePoints = polylinePoints.decodePolyline(
      encodedPolyline,
    );
    return decodePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }
}
