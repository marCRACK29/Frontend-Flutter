// location_service.dart
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final Location _location = Location();

  Future<LatLng?> getCurrentLocation() async {
    // Manejo de permisos aquí
    final locationData = await _location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }
}
