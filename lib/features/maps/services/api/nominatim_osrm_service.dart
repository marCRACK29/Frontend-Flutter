// nominatim_osrm_service.dart
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class NominatimOsrmService {
  Future<LatLng?> searchLocation(String query) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  Future<List<LatLng>> fetchRoute(LatLng from, LatLng to) async {
    final url = Uri.parse(
      "http://router.project-osrm.org/route/v1/driving/"
      '${from.longitude},${from.latitude};'
      '${to.longitude},${to.latitude}?overview=full&geometries=polyline',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      return _decodePolyline(geometry);
    }
    return [];
  }

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
