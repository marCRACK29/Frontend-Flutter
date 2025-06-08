import 'package:latlong2/latlong.dart';

class RouteResponse {
  final List<LatLng> coordinates;
  final double distance;
  final double duration;

  RouteResponse({
    required this.coordinates,
    required this.distance,
    required this.duration,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List;
    if (routes.isEmpty) {
      return RouteResponse(coordinates: [], distance: 0, duration: 0);
    }

    final route = routes[0];
    final geometry = route['geometry'];
    
    // Decode polyline coordinates
    final coordinates = <LatLng>[];
    if (geometry is List) {
      for (final coord in geometry) {
        if (coord is List && coord.length >= 2) {
          coordinates.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
        }
      }
    }

    return RouteResponse(
      coordinates: coordinates,
      distance: (route['distance'] ?? 0).toDouble(),
      duration: (route['duration'] ?? 0).toDouble(),
    );
  }
}
