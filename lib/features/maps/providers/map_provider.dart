import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/local/location_service.dart';
import '../services/api/nominatim_osrm_service.dart';

/// Proveedor de estado para el mapa que maneja la lógica de ubicación y rutas
class MapProvider with ChangeNotifier {
  final MapController mapController = MapController();

  /// Controlador del mapa para manipular la vista
  final TextEditingController searchController = TextEditingController();

  /// Controlador para el campo de búsqueda de ubicaciones
  final LocationService _locationService = LocationService();

  /// Servicio para obtener la ubicación actual del dispositivo
  final NominatimOsrmService _mapService = NominatimOsrmService();

  /// Servicio para buscar ubicaciones y calcular rutas usando OpenStreetMap

  LatLng? ubicacionActual;

  /// Ubicación actual del usuario
  LatLng? destino;

  /// Ubicación de destino seleccionada
  List<LatLng> route = [];

  /// Lista de puntos que forman la ruta entre la ubicación actual y el destino

  /// Indica si se está cargando la ubicación inicial
  bool isLoading = true;

  MapProvider() {
    _initLocation();
  }

  /// Inicializa la ubicación actual del usuario
  Future<void> _initLocation() async {
    ubicacionActual = await _locationService.getUbicacionActual();
    isLoading = false;
    notifyListeners();
  }

  /// Busca una ubicación y calcula la ruta hasta ella
  Future<void> searchLocation() async {
    final text = searchController.text.trim();
    if (text.isEmpty) return;

    // Busca las coordenadas de la ubicación ingresada
    destino = await _mapService.buscarUbicacion(text);

    // Si se encontró el destino y tenemos la ubicación actual, calcula la ruta
    if (destino != null && ubicacionActual != null) {
      route = await _mapService.fetchRoute(ubicacionActual!, destino!);
    }
    notifyListeners();
  }

  /// Centra el mapa en la ubicación actual del usuario
  void centerUserLocation() {
    if (ubicacionActual != null) {
      mapController.move(ubicacionActual!, 15);
    }
  }
}
