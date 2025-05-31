import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

/// Servicio que maneja la obtención de la ubicación actual del dispositivo
/// Utiliza el paquete 'location' para acceder a los servicios de ubicación nativos
class LocationService {
  /// Instancia del servicio de ubicación nativo
  final Location _location = Location();

  /// Obtiene la ubicación actual del dispositivo
  ///
  /// Retorna un objeto [LatLng] con la latitud y longitud actuales
  /// Retorna null si no se puede obtener la ubicación
  Future<LatLng?> getUbicacionActual() async {
    // Verificar si el servicio de ubicación está habilitado
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      // Solicitar activación del servicio de ubicación
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Verificar el estado de los permisos
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      // Solicitar permisos de ubicación
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return null;
      }
    }

    // Obtener la ubicación actual
    final locationData = await _location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }
}
